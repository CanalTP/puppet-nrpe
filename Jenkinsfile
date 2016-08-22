node('docker-puppet') {

  stage 'git checkout'
   
    checkout([$class: 'GitSCM', branches: [[name: '**']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'nrpe']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '66fdf51b-9438-4e4a-b65c-271906dda5b5', url: 'https://github.com/CanalTP/puppet-nrpe']]]) 

  stage 'puppet lint'

    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
      sh 'puppet-lint --no-documentation-check --no-140chars-check .'
    }

  stage 'r10k deployment'
 
    sshagent (['b1c38e32-372f-4e8a-b1f4-6a05b8df2f08']) {
      sh "mkdir ~/.ssh && chmod 0700 ~/.ssh"
      sh "echo -e 'Host *\n    StrictHostKeyChecking no' > ~/.ssh/config && chmod 0400 ~/.ssh/config"
      sh "ssh -A root@ctp-prd-foreman /opt/puppetlabs/puppet/bin/r10k deploy module -e production nrpe -v"
    }

}
