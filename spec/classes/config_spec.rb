require 'spec_helper'

describe 'nrpe::config', :type => :class do
  let :default_params do
    {
      :config_file_path  => '/etc/nagios',
      :config_file_name  => 'mongod.conf',
      :config_file_owner => 'root',
      :config_file_group => 'root',
      :config_file_mode  => '0644',
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

    it { is_expected.to contain_concat("/etc/nagios/nrpe.cfg").with( 
      :ensure => 'present', 
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

    it { is_expected.to contain_concat("/etc/nagios/nrpe.cfg").with( 
      :ensure => 'present', 
      :path   => '/etc/nagios/nrpe.cfg',
      :owner  => 'root', 
      :group  => 'root', 
      :mode   => '0644', 
      ) 
    } 

  end

end
