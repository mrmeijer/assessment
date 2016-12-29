#!/usr/bin/env ruby

require 'optparse'
require 'json'
require './lib/environment'
require './lib/instance'

options = {
  instance_count: 1,
  instance_type: 't2.micro',
  ssh_cidr_block: '0.0.0.0/0'
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: assignement.rb [options]'

  opts.on(
    '-i',
    '--instances instance_count',
    'Number of instances you want to create (default=1)'
  ) do |instance_count|
    options[:instance_count] = instance_count
  end

  opts.on(
    '-t',
    '--instance-type instance_type',
    'Type of instance you would like to create (default=t2.micro)'
  ) do |instance_type|
    options[:instance_type] = instance_type
  end

  opts.on(
    '-s',
    '--allow-ssh-from cidr_block',
    'The (set of) ip-adresses allowed to use ssh to instance (default all)'
  ) do |ssh_cidr_block|
    options[:ssh_cidr_block] = ssh_cidr_block
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

print "instance_count #{options[:instance_count]}\n"
print "instance_type #{options[:instance_type]}\n"
print "ssh_cidr_block #{options[:ssh_cidr_block]}\n"

$i = 0
@instances = []

while $i < options[:instance_count].to_i  do
   instance = Instance.new instance_type: options[:instance_type], ssh_cidr_block: options[:ssh_cidr_block] #, image_id: 'ami-b97a12ce' 
   @instances << instance
   $i +=1
end

