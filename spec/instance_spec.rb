# spec/instance_spec.rb
require 'instance'

describe Instance do
  describe '.new' do
    context 'no attributes given only defaults used' do
      it 'returns an object' do
        an_instance = Instance.new
        expect(an_instance).to be_an_instance_of(Instance)
      end
    end
  end
end
