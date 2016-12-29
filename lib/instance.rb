#!/usr/bin/env ruby

require 'aws-sdk'
require './lib/environment'

# lib/instance.rb
class Instance
  attr_reader :environment, :instance, :security_group

  def initialize(options = {})
    @environment = Environment.new
    @image_id = options[:image_id] || 'ami-1e299d7e'
    # this ssh_cidr_block is used for ssh access limitations
    self.security_group = options[:ssh_cidr_block] || '0.0.0.0/0'
    self.instance = options[:instance_type] || 't2.micro'
  end

  # can only be done after initializing the environment
  def security_group=(new_cidr_block)
    new_cidr_block = new_cidr_block + '/32' unless new_cidr_block.include? "/"
    @environment.vpc.security_groups.each do |sg|
      @security_group = sg if sg.group_name == 'SshSecurityGroup' + new_cidr_block
    end

    # only create security group if it does not exist
    if @security_group.nil?
      ec2 = Aws::EC2::Resource.new(region: 'us-west-2')

      @security_group = ec2.create_security_group(
        group_name: 'SshSecurityGroup' + new_cidr_block,
        description: 'Enable SSH access via port 22',
        vpc_id: @environment.vpc.id
      )

      @security_group.authorize_egress(
        ip_permissions: [
          ip_protocol: 'tcp',
          from_port: 22,
          to_port: 22,
          ip_ranges: [
            cidr_ip: new_cidr_block
          ]
        ]
      )
    end
  end

  def instance=(new_type)
    ec2 = Aws::EC2::Resource.new(region: 'us-west-2')

    @instance = ec2.create_instances(
      image_id: @image_id,
      min_count: 1,
      max_count: 1,
      security_group_ids: [@security_group.id],
      instance_type: new_type,
      placement: {
        availability_zone: @environment.availability_zone
      },
      subnet_id: @environment.subnet.id,
    )[0]

    # Wait for the instance to be created, running, and passed status checks
    ec2.client.wait_until(:instance_status_ok, {instance_ids: [@instance.id]})

    @instance.create_tags(tags: [{ key: 'Name', value: 'InstanceName' }, { key: 'Group', value: 'InstanceGroup' }])
  end
end

