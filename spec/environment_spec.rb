# spec/environment_spec.rb
require 'environment'

describe Environment do
  describe '.new' do
    context 'no attributes given only defaults used' do
      it 'returns an object' do
        an_environment = Environment.new
        expect(an_environment).to be_an_instance_of(Environment)
      end
    end

    context 'only vpc_id is given' do
      it 'vpc_id exists in the EC2, the selected vpc returned' do
        an_environment = Environment.new vpc_id: 'vpc-0961cd6e'
        expect(an_environment.vpc.id).to eql('vpc-0961cd6e')
      end

      it 'vpc_id does not exist in the EC2, the default vpc returned' do
        an_environment = Environment.new vpc_id: 'vpc-xxxcd6e'
        expect(an_environment.vpc.id).not_to eql('vpc-xxxcd6e')
        expect(an_environment.vpc.is_default).to eql(true)
      end

      it 'vpc_id exists in the EC2, the selected vpc and subnet checked' do
        an_environment = Environment.new vpc_id: 'vpc-0961cd6e'
        expect(an_environment.vpc.id).to eql('vpc-0961cd6e')
        expect(an_environment.subnet.id).to eql('subnet-9d5f93fa')
      end

      it 'vpc_id does not exist in the EC2, default vpc and subnet checked' do
        an_environment = Environment.new vpc_id: 'vpc-xxxcd6e'
        expect(an_environment.vpc.id).not_to eql('vpc-xxxcd6e')
        expect(an_environment.vpc.is_default).to eql(true)
        expect(an_environment.subnet.id).to eql('subnet-2ba1634c')
      end
    end
  end
end
