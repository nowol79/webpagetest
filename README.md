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
  
  
  > install status page - http://WPT_HOST:80/install
  
Test Location has not yet been connected.

