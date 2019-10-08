# Fundus Image Classifier and Comparator

Purpose: Set up a static webpage and server to host classifier/comparator tasks for ophthalmologists and collect classification/comparison data for analysis

I am not the original author of these files. This repository contains aggregated and updated files from previous developers. See acknowledgement below.

## Instructions for use
1. Set up AWS instance. Free tier is adequate for deployment on a small scale.You will need your public host IP or DNS and SFTP access (prefer Filezilla) to make docker setup easier
2. SSH to your server using your custom command provided by AWS. SFTP and move dockerfile to the root dir of your AWS server 
3. Create docker image using instructions described here: https://github.com/CollinWen/Image-Comparator-Dockerfile
4. Deploy server using the following:
```python -m SimpleHTTPServer 8080```
5. Use tmux before running the above command to allow the server to run indefinitely

## Acknowledgements
Jayashree Kalpathy-Cramer, PhD for original source code (https://github.com/AlanCramer/Image-Comparator)

Collin Wen, for dockerized image (https://github.com/CollinWen/Image-Comparator-Dockerfile)

## Contact
For questions, please contact:
Jimmy Chen, chenjim@ohsu.edu
