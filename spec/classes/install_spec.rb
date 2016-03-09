require 'spec_helper'

describe 'nrpe::install', :type => :class do
  context "on Debian" do
    let :facts do
      {
        :osfamily => 'Debian',
      }
    end

    context "version 7" do
      let :facts do
        {
          :operatingsystemmajrelease => '7',
          :lsbdistcodename           => 'wheezy',
        }
      end
      describe 'Standard package installation' do
	let :params do 
	  { 
	    :package_name   => ['nagios-nrpe-server', 'nagios-plugins'], 
	    :package_ensure => 'installed',
	  }
	end
        it { is_expected.to contain_package('nagios-nrpe-server').with_ensure('installed') }
        it { is_expected.to contain_package('nagios-plugins').with_ensure('installed') }
      end
    end

    context "version 8" do
      let :facts do
        {
          :operatingsystemmajrelease => '8.0',
          :lsbdistcodename           => 'jessie',
        }
      end
      describe 'Standard package installation' do
	let :params do 
	  { 
	    :package_name   => ['nagios-nrpe-server', 'nagios-plugins'], 
	    :package_ensure => 'installed',
	  }
	end
        it { is_expected.to contain_package('nagios-nrpe-server').with_ensure('installed') }
        it { is_expected.to contain_package('nagios-plugins').with_ensure('installed') }
      end
    end

  end
  
  context "on RedHat" do
    let :facts do
      {
        :osfamily        => 'RedHat',
      }
    end

    context "version 6" do
      let :facts do
        {
          :operatingsystemmajrelease => '6',
        }
      end
      describe 'Standard package installation' do
	let :params do 
	  { 
	    :package_name   => ['nrpe', 'nagios-plugins-all'], 
	    :package_ensure => 'installed',
	  }
	end
        it { is_expected.to contain_package('nrpe').with_ensure('installed') }
        it { is_expected.to contain_package('nagios-plugins-all').with_ensure('installed') }
      end
    end

    context "version 7" do
      let :facts do
        {
          :operatingsystemajrelease => '7',
        }
      end
      describe 'Standard package installation' do
	let :params do 
	  { 
	    :package_name   => ['nrpe', 'nagios-plugins-all'], 
	    :package_ensure => 'installed',
	  }
	end
        it { is_expected.to contain_package('nrpe').with_ensure('installed') }
        it { is_expected.to contain_package('nagios-plugins-all').with_ensure('installed') }
      end
    end

  end

end
