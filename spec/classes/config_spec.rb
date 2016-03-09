require 'spec_helper'

describe 'nrpe::config', :type => :class do
  let :default_params do
    {
      :config_nrpe_ensure => 'file',
      :config_nrpe_user   => 'root',
      :config_nrpe_group  => 'root',
    }
  end

  context "on Debian" do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :lsbdistid       => 'Debian',
      }
    end
    let :params do default_params end

    it { is_expected.to contain_file("/etc/nagios/nrpe.cfg").with( 
      :ensure => 'file', 
      :path   => '/etc/nagios/nrpe.cfg',
      :owner  => 'root', 
      :group  => 'root', 
      :mode   => '0644', 
      ) 
    } 

  end
  
  context "on RedHat" do
    let :facts do
      {
        :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
        :lsbdistid       => 'RedHat',
      }
    end
    let :params do default_params end

    it { is_expected.to contain_file("/etc/nagios/nrpe.cfg").with( 
      :ensure => 'file', 
      :path   => '/etc/nagios/nrpe.cfg',
      :owner  => 'root', 
      :group  => 'root', 
      :mode   => '0644', 
      ) 
    } 

  end

end
