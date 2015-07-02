docker stop wpt && docker rm wpt && docker run --name wpt -d -p 8080:80 -v /var/lib/docker/data/fep/wpt-results:/var/www/html/results jeroenvdb/webpagetest
