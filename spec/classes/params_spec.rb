require 'spec_helper'

describe 'nrpe::params', :type => :class do
  context "On a RedHat OS" do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '7',
      }
    end

    it "Should not contain any resources" do
      should have_resource_count(0)
    end
  end
end
