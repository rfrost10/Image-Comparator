# Fundus Image Classifier and Comparator

Purpose: Set up a static webpage and server to host classifier/comparator tasks for ophthalmologists and collect classification/comparison data on retinal fundus images for data analysis

I am not the original author of these files. This repository contains aggregated and updated files from previous developers. See acknowledgements below.

## Instructions for use
1. Set up AWS instance. Free tier is adequate for small scale deployment. I also recommend setting up an SFTP client such as FileZilla for easier file transfer (will require your public IPv4/DNS) 
2. SSH to your server using your custom command/security key provided by AWS. Move dockerfile to the root directory of your AWS server 
3. Create docker image using instructions described here: https://github.com/CollinWen/Image-Comparator-Dockerfile
4. Deploy server using the following:
```python -m SimpleHTTPServer 8080```
5. Use tmux to before deploying the server to allow the server to run indefinitely

## Acknowledgements
Jayashree Kalpathy-Cramer, PhD for original source code (https://github.com/AlanCramer/Image-Comparator)

Collin Wen, for dockerized image (https://github.com/CollinWen/Image-Comparator-Dockerfile)

## Contact
For questions, please contact:
Jimmy Chen, chenjim@ohsu.edu
