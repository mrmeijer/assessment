#!/usr/bin/env ruby

require 'aws-sdk'

# lib/environment.rb
class Environment
  attr_accessor :region, :availability_zone
  attr_reader :vpc, :igw, :subnet, :route_table

  def initialize(options = {})
    self.region = options[:region] || 'us-west-2'
    self.availability_zone = options[:availability_zone] || 'us-west-2a'
    self.vpc = options[:vpc_id]
    self.gateway = options[:igw_id]
    self.subnet = options[:subnet_id]
    self.route_table = options[:cidr_block] || '0.0.0.0/0'
  end

  def vpc=(new_vpc_id)
    ec2 = Aws::EC2::Resource.new(region: @region)

    ec2.vpcs.each do |vpc|
      @vpc = vpc if new_vpc_id == vpc.id || (vpc.is_default && @vpc.nil?)
    end

    # create Virtual Private Cloud if not available
    if @vpc.nil?
      ec2 = Aws::EC2::Resource.new(region: @region)
      vpc = ec2.create_vpc(cidr_block: '10.75.0.0/16')

      # make sure a public DNS is available
      vpc.modify_attribute(enable_dns_support: { value: true })
      vpc.modify_attribute(enable_dns_hostnames: { value: true })

      # Give the VPC a name
      vpc.create_tags(tags: [{ key: 'Name', value: 'AssignmentVPC' }])
    end
  end

  def subnet=(new_subnet_id)
    @vpc.subnets.each do |subnet|
      @subnet = subnet if new_subnet_id == subnet.id || (subnet.availability_zone == @availability_zone && @subnet.nil?)
    end

    # create subnet if not available, only possible after creating a VPC
    # assumption is that the cidr block of the vpc is of 16 bits
    if @subnet.nil?
      ec2 = Aws::EC2::Resource.new(region: @region)

      @subnet = ec2.create_subnet(
        vpc_id: @vpc.id,
        cidr_block: @vpc.cidr_block.gsub(%r[\d{1,3}\.\d{1,3}/16], '32.0/20'),
        availability_zone: @availability_zone
      )

      @subnet.create_tags(tags: [{ key: 'Name', value: 'AssignmentSubnetA' }])
    end
  end

  def gateway=(new_igw_id)
    @vpc.internet_gateways.each do |igw|
      @gateway = igw if new_igw_id == igw.id || @igw.nil?
    end

    # create internet gateway if not available, only possible after creating a VPC
    if @gateway.nil?
      ec2 = Aws::EC2::Resource.new(region: @region)

      @gateway = ec2.create_internet_gateway

      @gateway.create_tags(tags: [{ key: 'Name', value: 'AssignmentGateway' }])
      @gateway.attach_to_vpc(vpc_id: @vpc.id)
    end
  end

  # just always create a new apropriate route
  # check on destination_cidr_block does not seem to work
  def route_table=(new_cidr_block)
    ec2 = Aws::EC2::Resource.new(region: @region)

    @route_table = ec2.create_route_table(vpc_id: @vpc.id)

    @route_table.create_tags(tags: [{ key: 'Name', value: 'AssignmentRouteTable' }])
    @route_table.create_route(
      destination_cidr_block: new_cidr_block,
      gateway_id: @gateway.id
    )
  end
end
