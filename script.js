// Loader fade-out
window.onload = () => {
    setTimeout(() => {
        document.getElementById("loader").style.display = "none";
    }, 1200);
};

// Show menu section with animation
function showSection(sectionId, btn) {

    // Hide landing with fade-out (only first time)
    const landing = document.getElementById("landing");
    if (landing && landing.style.display !== 'none') {
        landing.classList.add("fade-out");
        setTimeout(() => {
            landing.style.display = "none";
        }, 500);
    }

    // Hide all menu sections
    document.querySelectorAll(".menu-section").forEach(sec => {
        sec.classList.add("hidden");
    });

    // Remove active state from buttons
    document.querySelectorAll('.menu-buttons button').forEach(b => b.classList.remove('active'));

    // Show selected section
    const section = document.getElementById(sectionId);
    if (!section) return;
    section.classList.remove("hidden");

    // Set active button style
    if (btn && btn.classList) btn.classList.add('active');

    // Restart animation
    section.style.animation = "none";
    void section.offsetWidth; // reset trick
    section.style.animation = "fadeSlide .6s ease forwards";

    // scroll into view on small screens
    section.scrollIntoView({behavior: 'smooth', block: 'start'});
}

// Show landing again (reverse of showSection)
function showLanding(){
    // hide sections
    document.querySelectorAll('.menu-section').forEach(sec=>{
        sec.classList.add('hidden');
        // reset item animations
        sec.querySelectorAll('.menu-row').forEach(r=>{ r.style.removeProperty('--delay'); r.style.animation = 'none'});
    });

    // remove active state
    document.querySelectorAll('.menu-buttons button').forEach(b=>b.classList.remove('active'));

    const landing = document.getElementById('landing');
    if (!landing) return;
    landing.style.display = 'block';
    landing.classList.remove('fade-out');
    // add fade-in so it appears smoothly
    landing.classList.add('fade-in');
    landing.scrollIntoView({behavior:'smooth', block:'start'});
}

// When showing a section, stagger its menu rows animation
const originalShowSection = showSection;
showSection = function(sectionId, btn){
    originalShowSection(sectionId, btn);
    const section = document.getElementById(sectionId);
    if (!section) return;
    const rows = Array.from(section.querySelectorAll('.menu-row'));
    rows.forEach((r,i)=>{
        r.style.animation = 'none';
        // give a small stagger
        r.style.setProperty('--delay', (i * 0.06) + 's');
        // force reflow and reapply
        void r.offsetWidth;
        r.style.animation = 'itemIn .45s ease forwards';
    });
}
