var url1 = "http://image-comparator.westeurope.cloudapp.azure.com:5984/images_db/32/image"

console.log('TEST')
fetch(url1)
  .then(response => {response.json();})
  .then(data => console.log(data));