window.onload = function () {
    // Add click event to logo if it exists
    var logoElement = document.getElementsByClassName('kc-logo-text')[0];
    if (logoElement) {
        logoElement.addEventListener('click', function () {
            location.href = 'https://scoring.sme.go.th';
        }, false);
    }

    // Update register link if it exists
    var links = document.getElementsByTagName("a");
    if (links && links.length > 1 && links[1]) {
        links[1].href = "https://scoring.sme.go.th/register";
    }
}