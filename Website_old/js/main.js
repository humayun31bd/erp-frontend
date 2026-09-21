/* ============================================================
   ZATCA Engine — Main Interactions Module
   ============================================================ */

document.addEventListener('DOMContentLoaded', () => {
  initNavbar();
  initMobileNav();
  initScrollReveal();
  initParticles();
  initFaqAccordion();
  initPricingToggle();
  initTestimonials();
  initCounterAnimation();
  initSmoothScroll();
  initContactForm();
  initDemoSteps();
});

/* ---------- Navbar Scroll Effect ---------- */
function initNavbar() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;

  const handleScroll = () => {
    if (window.scrollY > 50) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  };

  window.addEventListener('scroll', handleScroll, { passive: true });
  handleScroll();

  // Active link highlighting
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.navbar__link').forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentPage || (currentPage === '' && href === 'index.html')) {
      link.classList.add('active');
    }
  });
}

/* ---------- Mobile Navigation ---------- */
function initMobileNav() {
  const hamburger = document.querySelector('.navbar__hamburger');
  const mobileNav = document.querySelector('.mobile-nav');
  if (!hamburger || !mobileNav) return;

  hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    mobileNav.classList.toggle('active');
    document.body.style.overflow = mobileNav.classList.contains('active') ? 'hidden' : '';
  });

  mobileNav.querySelectorAll('.mobile-nav__link').forEach(link => {
    link.addEventListener('click', () => {
      hamburger.classList.remove('active');
      mobileNav.classList.remove('active');
      document.body.style.overflow = '';
    });
  });
}

/* ---------- Scroll Reveal Animations ---------- */
function initScrollReveal() {
  const revealElements = document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .reveal-scale, .stagger-children, .step-item');
  if (!revealElements.length) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  });

  revealElements.forEach(el => observer.observe(el));
}

/* ---------- Particle Hero Background ---------- */
function initParticles() {
  const canvas = document.querySelector('.hero__canvas');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  let particles = [];
  let animationId;
  let width, height;

  function resize() {
    width = canvas.width = canvas.parentElement.offsetWidth;
    height = canvas.height = canvas.parentElement.offsetHeight;
  }

  function createParticle() {
    return {
      x: Math.random() * width,
      y: Math.random() * height,
      size: Math.random() * 2 + 0.5,
      speedX: (Math.random() - 0.5) * 0.5,
      speedY: (Math.random() - 0.5) * 0.5,
      opacity: Math.random() * 0.5 + 0.1,
      color: Math.random() > 0.5 ? '0, 212, 170' : '14, 165, 233'
    };
  }

  function initParticleArray() {
    const count = Math.min(Math.floor((width * height) / 15000), 80);
    particles = Array.from({ length: count }, createParticle);
  }

  function drawParticles() {
    ctx.clearRect(0, 0, width, height);

    particles.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(${p.color}, ${p.opacity})`;
      ctx.fill();

      p.x += p.speedX;
      p.y += p.speedY;

      if (p.x < 0 || p.x > width) p.speedX *= -1;
      if (p.y < 0 || p.y > height) p.speedY *= -1;
    });

    // Draw connections
    for (let i = 0; i < particles.length; i++) {
      for (let j = i + 1; j < particles.length; j++) {
        const dx = particles[i].x - particles[j].x;
        const dy = particles[i].y - particles[j].y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < 150) {
          ctx.beginPath();
          ctx.strokeStyle = `rgba(0, 212, 170, ${0.05 * (1 - dist / 150)})`;
          ctx.lineWidth = 0.5;
          ctx.moveTo(particles[i].x, particles[i].y);
          ctx.lineTo(particles[j].x, particles[j].y);
          ctx.stroke();
        }
      }
    }

    animationId = requestAnimationFrame(drawParticles);
  }

  resize();
  initParticleArray();
  drawParticles();

  window.addEventListener('resize', () => {
    resize();
    initParticleArray();
  });

  // Pause when not visible
  const observer = new IntersectionObserver(([entry]) => {
    if (entry.isIntersecting) {
      if (!animationId) drawParticles();
    } else {
      cancelAnimationFrame(animationId);
      animationId = null;
    }
  }, { threshold: 0 });

  observer.observe(canvas.parentElement);
}

/* ---------- FAQ Accordion ---------- */
function initFaqAccordion() {
  document.querySelectorAll('.faq-item__question').forEach(btn => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const answer = item.querySelector('.faq-item__answer');
      const isActive = item.classList.contains('active');

      // Close all
      document.querySelectorAll('.faq-item').forEach(faq => {
        faq.classList.remove('active');
        faq.querySelector('.faq-item__answer').style.maxHeight = '0';
      });

      // Open if was closed
      if (!isActive) {
        item.classList.add('active');
        answer.style.maxHeight = answer.scrollHeight + 'px';
      }
    });
  });
}

/* ---------- Pricing Toggle ---------- */
function initPricingToggle() {
  const toggle = document.querySelector('.pricing-toggle__switch');
  if (!toggle) return;

  const monthlyLabel = document.querySelector('[data-pricing="monthly"]');
  const yearlyLabel = document.querySelector('[data-pricing="yearly"]');

  toggle.addEventListener('click', () => {
    toggle.classList.toggle('yearly');
    const isYearly = toggle.classList.contains('yearly');

    if (monthlyLabel) monthlyLabel.classList.toggle('active', !isYearly);
    if (yearlyLabel) yearlyLabel.classList.toggle('active', isYearly);

    // Update prices
    document.querySelectorAll('[data-price-monthly]').forEach(el => {
      const monthly = el.getAttribute('data-price-monthly');
      const yearly = el.getAttribute('data-price-yearly');
      animateValue(el, parseInt(el.textContent), parseInt(isYearly ? yearly : monthly), 400);
    });

    // Update period text
    document.querySelectorAll('[data-period]').forEach(el => {
      const lang = document.documentElement.lang || 'en';
      if (isYearly) {
        el.textContent = lang === 'ar' ? '/شهر، يُدفع سنويًا' : '/month, billed yearly';
      } else {
        el.textContent = lang === 'ar' ? '/شهر' : '/month';
      }
    });
  });
}

/* ---------- Testimonials Carousel ---------- */
function initTestimonials() {
  const track = document.querySelector('.testimonials-track');
  const prevBtn = document.querySelector('[data-testimonial="prev"]');
  const nextBtn = document.querySelector('[data-testimonial="next"]');
  if (!track) return;

  let currentIndex = 0;
  const cards = track.querySelectorAll('.testimonial-card');
  if (!cards.length) return;

  function getCardWidth() {
    return cards[0].offsetWidth + 24; // card width + gap
  }

  function slide(direction) {
    const maxIndex = Math.max(0, cards.length - Math.floor(track.parentElement.offsetWidth / getCardWidth()));
    currentIndex = Math.max(0, Math.min(maxIndex, currentIndex + direction));
    track.style.transform = `translateX(${-currentIndex * getCardWidth()}px)`;
  }

  if (prevBtn) prevBtn.addEventListener('click', () => slide(-1));
  if (nextBtn) nextBtn.addEventListener('click', () => slide(1));

  // Auto-advance
  let autoSlide = setInterval(() => {
    if (currentIndex >= cards.length - 1) {
      currentIndex = -1;
    }
    slide(1);
  }, 5000);

  track.parentElement.addEventListener('mouseenter', () => clearInterval(autoSlide));
  track.parentElement.addEventListener('mouseleave', () => {
    autoSlide = setInterval(() => {
      if (currentIndex >= cards.length - 1) currentIndex = -1;
      slide(1);
    }, 5000);
  });
}

/* ---------- Counter Animation ---------- */
function initCounterAnimation() {
  const counters = document.querySelectorAll('[data-counter]');
  if (!counters.length) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting && !entry.target.dataset.counted) {
        entry.target.dataset.counted = 'true';
        const target = parseInt(entry.target.getAttribute('data-counter'));
        const prefix = entry.target.getAttribute('data-counter-prefix') || '';
        const suffix = entry.target.getAttribute('data-counter-suffix') || '';
        animateValue(entry.target, 0, target, 2000, prefix, suffix);
      }
    });
  }, { threshold: 0.3 });

  counters.forEach(el => observer.observe(el));
}

function animateValue(el, start, end, duration, prefix = '', suffix = '') {
  const startTime = performance.now();
  const range = end - start;

  function update(currentTime) {
    const elapsed = currentTime - startTime;
    const progress = Math.min(elapsed / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3); // ease-out cubic
    const current = Math.floor(start + range * eased);
    el.textContent = prefix + current.toLocaleString() + suffix;

    if (progress < 1) {
      requestAnimationFrame(update);
    }
  }

  requestAnimationFrame(update);
}

/* ---------- Smooth Scroll ---------- */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
      e.preventDefault();
      const target = document.querySelector(anchor.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
}

/* ---------- Contact Form ---------- */
function initContactForm() {
  const form = document.querySelector('#contact-form');
  if (!form) return;

  form.addEventListener('submit', (e) => {
    e.preventDefault();

    const btn = form.querySelector('button[type="submit"]');
    const originalText = btn.textContent;
    btn.textContent = '✓ Message Sent!';
    btn.style.background = 'var(--accent-green)';
    btn.disabled = true;

    setTimeout(() => {
      btn.textContent = originalText;
      btn.style.background = '';
      btn.disabled = false;
      form.reset();
    }, 3000);
  });

  // Demo form
  const demoForm = document.querySelector('#demo-form');
  if (!demoForm) return;

  demoForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const btn = demoForm.querySelector('button[type="submit"]');
    const originalText = btn.textContent;
    btn.textContent = '✓ Credentials Sent!';
    btn.style.background = 'var(--accent-green)';
    btn.disabled = true;

    setTimeout(() => {
      btn.textContent = originalText;
      btn.style.background = '';
      btn.disabled = false;
      demoForm.reset();
    }, 3000);
  });
}

/* ---------- Demo Steps Interactive ---------- */
function initDemoSteps() {
  const stepBtns = document.querySelectorAll('[data-demo-step]');
  if (!stepBtns.length) return;

  stepBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const stepNum = btn.getAttribute('data-demo-step');

      // Update active button
      stepBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      // Show corresponding panel
      document.querySelectorAll('.demo-panel').forEach(panel => {
        panel.classList.remove('active');
      });
      const target = document.querySelector(`#demo-panel-${stepNum}`);
      if (target) target.classList.add('active');
    });
  });
}
