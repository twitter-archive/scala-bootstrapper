#!/bin/bash
echo "Starting birdname in development mode..."
java -server -Xmx1024m -Dstage=development -jar ./dist/birdname/birdname-@VERSION@.jar
