require 'spec_helper'

describe 'nrpe', :type => :class do

  context "On Ddebian 7" do
    let :facts do
      {
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Debian',
        :lsbdistid                 => 'Debian',
	:operatingsystemmajrelease => '7',
        :lsbdistcodename           => 'wheezy',
      }
    end
    it { is_expected.to compile }
    it { is_expected.to contain_class('nrpe::install') }
    it { is_expected.to contain_class('nrpe::config') }
    it { is_expected.to contain_class('nrpe::service') }
  end

  context "On Debian 8" do
    let :facts do
      {
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Debian',
        :lsbdistid                 => 'Debian',
        :operatingsystemmajrelease => '8',
        :lsbdistcodename           => 'jessie',
      }
    end
    it { is_expected.to compile }
    it { is_expected.to contain_class('nrpe::install') }
    it { is_expected.to contain_class('nrpe::config') }
    it { is_expected.to contain_class('nrpe::service') }
  end
  
  context "on RedHat 6" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :lsbdistid              => 'RedHat',
        :operatingsystemrelease => '6.0',
      }
    end
    it { is_expected.to compile }
    it { is_expected.to contain_class('nrpe::install') }
    it { is_expected.to contain_class('nrpe::config') }
    it { is_expected.to contain_class('nrpe::service') }
  end

  context "on RedHat 7" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :lsbdistid              => 'RedHat',
        :operatingsystemrelease => '7.0',
      }
    end
    it { is_expected.to compile }
    it { is_expected.to contain_class('nrpe::install') }
    it { is_expected.to contain_class('nrpe::config') }
    it { is_expected.to contain_class('nrpe::service') }
  end

end
