let hideTimeout = null;

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action !== 'showBadge') return;

    const container = document.getElementById('badge-container');

    document.getElementById('id-title').innerText = data.idTitle || 'IDENTIFICATION';
    document.getElementById('badge-image').src = 'images/' + data.image;
    document.getElementById('badge-department').innerText = data.department;
    document.getElementById('badge-officer').innerText = data.officer;
    document.getElementById('badge-rank').innerText = data.rank || '—';
    document.getElementById('badge-callsign').innerText = data.callsign;
    document.getElementById('badge-signature').innerText = data.signature || '';
    document.getElementById('wallet').style.setProperty('--accent-color', data.color || '#caa14b');

    container.classList.remove('hidden');
    // force reflow so the transition replays if triggered again quickly
    void container.offsetWidth;
    container.classList.add('show');

    clearTimeout(hideTimeout);
    hideTimeout = setTimeout(() => {
        container.classList.remove('show');
        setTimeout(() => container.classList.add('hidden'), 250);
    }, data.duration || 6000);
});
