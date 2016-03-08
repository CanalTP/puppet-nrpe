#nrpe

####Table of Contents
1. [Overview - What is the nrpe module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with nrpe](#setup)
4. [Limitations - OS compatibility, etc.](#limitations)

##Overview

The nrpe module allows you to set up the nrpe on each agent.

##Module Description

The module can update the nrpe server packages. It also sets up the nrpe configuration and the common checks.

##Setup

**What nrpe affects:**

* `/etc/nagios/nrpe.cfg`
* `/etc/XXX/nrpe.d/`

###Beginning with nrpe

##Limitations

This module has been validated on:

* Debian:
    * 7 x86_64
    * 8 x86_64
* RedHat: 
    * 6 x86_64
    * 7 x86_64
