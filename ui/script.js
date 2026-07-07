let hideTimeout = null;
let hiddenTimeout = null;

function setBadgePhoto(photoUrl) {
    const photoWrapper = document.querySelector('.id-photo');
    const photo = document.getElementById('badge-photo');

    photo.onerror = () => {
        photo.onerror = null;
        photo.classList.add('hidden');
        photoWrapper.classList.remove('has-photo');
        photo.removeAttribute('src');
    };

    if (photoUrl) {
        photo.src = photoUrl;
        photo.classList.remove('hidden');
        photoWrapper.classList.add('has-photo');
    } else {
        photo.classList.add('hidden');
        photoWrapper.classList.remove('has-photo');
        photo.removeAttribute('src');
    }
}

function hideBadge() {
    const container = document.getElementById('badge-container');

    clearTimeout(hideTimeout);
    clearTimeout(hiddenTimeout);
    container.classList.remove('show');
    hiddenTimeout = setTimeout(() => {
        container.classList.add('hidden');
        setBadgePhoto(null);
    }, 250);
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'setBadgePhoto') {
        setBadgePhoto(data.photo);
        return;
    }

    if (data.action === 'hideBadge') {
        hideBadge();
        return;
    }

    if (data.action !== 'showBadge') return;

    const container = document.getElementById('badge-container');
    setBadgePhoto(data.photo);

    document.getElementById('id-title').innerText = data.idTitle || 'IDENTIFICATION';
    document.getElementById('badge-image').src = 'images/' + data.image;
    document.getElementById('badge-department').innerText = data.department;
    document.getElementById('badge-officer').innerText = data.officer;
    document.getElementById('badge-rank').innerText = data.rank || '—';
    document.getElementById('badge-callsign').innerText = data.callsign;
    document.getElementById('badge-signature').innerText = data.signature || '';
    document.getElementById('wallet').style.setProperty('--accent-color', data.color || '#caa14b');

    clearTimeout(hideTimeout);
    clearTimeout(hiddenTimeout);
    container.classList.remove('hidden');
    // force reflow so the transition replays if triggered again quickly
    void container.offsetWidth;
    container.classList.add('show');

    hideTimeout = setTimeout(hideBadge, data.duration || 6000);
});
