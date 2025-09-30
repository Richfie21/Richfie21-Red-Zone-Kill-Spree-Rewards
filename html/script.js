window.addEventListener('message', function (event) {
    if (event.data.action === 'show') {
        document.getElementById('hud').style.display = 'block';
        document.getElementById('zoneName').innerText = event.data.zone;
        updateStats(event.data.stats);

    } else if (event.data.action === 'hide') {
        document.getElementById('hud').style.display = 'none';

    } else if (event.data.action === 'update') {
        updateStats(event.data.stats);  
    } else if (event.data.action === 'showSpree') { 
        showSpreeText(event.data.spree, event.data.text, event.data.color, event.data.shadow); 
        let audio = new Audio(`sounds/${event.data.spree}.mp3`);
        audio.volume = 0.7;
        audio.play().catch(err => console.error("Audio error:", err));
    } else if (event.data.action === 'hideSpree') {
        const spreeEl = document.getElementById('spreeText');
        if (spreeEl) {
            spreeEl.style.opacity = 0;
            spreeEl.style.animation = 'none';
        }
    }
});

function updateStats(stats) {
    document.getElementById('kills').innerText = stats.kills;
    document.getElementById('deaths').innerText = stats.deaths;
    document.getElementById('spree').innerText = stats.spree;
}
 
function showSpreeText(spreeName, textlabel, color, shadow) {
    const spreeEl = document.getElementById('spreeText');
   
    const displayText = textlabel || textlabel.toUpperCase();
    spreeEl.innerText = displayText;
   
    spreeEl.style.color = color;
    spreeEl.style.textShadow = shadow;
 
    spreeEl.style.animation = "none";
    spreeEl.offsetHeight;  
    spreeEl.style.animation = "spreeAnim 2s ease forwards";
}
 
 