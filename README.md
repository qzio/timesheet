# simple time tracker using sinatra and files.

to get started:

    ruby ts.rb


goto http://localhost:4567 , or use something like curl

    curl -X POST -F "cmd=start" localhost:4567
    curl -X POST -F "cmd=stop" localhost:4567
