document.addEventListener("DOMContentLoaded", () => {
    let watermark = document.getElementById('watermark');

    window.addEventListener('message', function(event) {
        const id = event.data.id
        const spillere = event.data.spillere


        
        watermark.innerHTML = "<h3>I Byen: "+ spillere +" | Dit ID: "+ id +"</h3>";
    });
});