# webpagetest
[webpagetest.org](www.webpagetest.org) private instance Docker build file 

Quick Start
===
* install docker (recommand 1.10.0 higher)  
* docker image repository [nowol/webpagetest](https://hub.docker.com/r/nowol/webpagetest/)
* run container
```
$ docker pull nowol/webpagetest
$ docker run -d -p 80:80 -v /tmp/wpt/result:/var/www/html/result --name webpagetest-2.19 nowol/webpagetest
```
After running OK!, You can check the main page & status page through a browser!!
  >  main page - http://WPT_HOST:80

  ![wpt](https://cloud.githubusercontent.com/assets/9585881/15988052/5c5fd07e-307d-11e6-8071-c182a0a555df.PNG)
  
  > install status page - http://WPT_HOST:80/install
  
  ![wpt_install](https://cloud.githubusercontent.com/assets/9585881/15988053/5f3d18d8-307d-11e6-981f-9a7074f4e3b7.PNG)
  

Test Location Setting
=====
After webpagetest running, Test Location has not yet been connected.
Let's set the PC/Mobile location through location.ini


