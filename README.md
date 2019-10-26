# Fundus Image Classifier and Comparator

Purpose: Set up a static webpage and server to host classifier/pairwise comparator tasks for images 

I am not the original author of these files. This repository contains aggregated and updated files from previous developers. See acknowledgements below.

## Instructions for use
1. Set up AWS instance. Free tier is adequate for small scale deployment. I also recommend setting up an SFTP client such as FileZilla for easier file transfer (will require your public IPv4/DNS) 
2. SSH to your server using your custom command/security key provided by AWS. Move dockerfile to the root directory of your AWS server 
3. Create docker image using instructions described here: https://github.com/CollinWen/Image-Comparator-Dockerfile
4. Of note, the above repository's dockerfile works, but does not work completely, and some of the webpage code did not work. I have attached my proposed fixes in my dockerfile but have not been able to verify if it works. If the dockerfile above does not work for you, I would recommend replacing the above repository's files with this repository's files and using sed to replace all of my IP addrresses with your server's.
5. Deploy server using the following:
```python -m SimpleHTTPServer 8080```
6. Use tmux to before deploying the server to allow the server to run indefinitely

## Acknowledgements
Jayashree Kalpathy-Cramer, PhD for original source code (https://github.com/AlanCramer/Image-Comparator)

Collin Wen, for dockerized image (https://github.com/CollinWen/Image-Comparator-Dockerfile)

## Contact
For questions, please contact:
Jimmy Chen, chenjim@ohsu.edu
