/* ============================================================
   ZATCA Engine — ROI Calculator Module
   ============================================================ */

document.addEventListener('DOMContentLoaded', () => {
  initROICalculator();
});

function initROICalculator() {
  const calculator = document.querySelector('.roi-calculator');
  if (!calculator) return;

  const invoicesSlider = calculator.querySelector('#roi-invoices');
  const hoursSlider = calculator.querySelector('#roi-hours');
  const valueSlider = calculator.querySelector('#roi-value');

  const invoicesDisplay = calculator.querySelector('#roi-invoices-value');
  const hoursDisplay = calculator.querySelector('#roi-hours-value');
  const valueDisplay = calculator.querySelector('#roi-value-value');

  const resultHours = calculator.querySelector('#roi-result-hours');
  const resultPenalty = calculator.querySelector('#roi-result-penalty');
  const resultCost = calculator.querySelector('#roi-result-cost');
  const resultSpeed = calculator.querySelector('#roi-result-speed');
  const penaltyCard = calculator.querySelector('.roi-result--highlight');

  if (!invoicesSlider || !hoursSlider || !valueSlider) return;

  function calculate() {
    const invoices = parseInt(invoicesSlider.value);
    const hours = parseFloat(hoursSlider.value);
    const avgValue = parseInt(valueSlider.value);

    // Display current values
    invoicesDisplay.textContent = invoices.toLocaleString();
    hoursDisplay.textContent = hours.toFixed(1);
    valueDisplay.textContent = avgValue.toLocaleString() + ' SAR';

    // Calculations
    const automationRate = 0.95; // 95% automation
    const hoursSaved = Math.round(invoices * hours * automationRate);
    const hourlyRate = 50; // SAR per hour average
    const penaltyPerInvoice = 10000; // SAR ZATCA penalty per non-compliant invoice
    const penaltyRisk = Math.round(invoices * 12 * 0.05 * penaltyPerInvoice); // 5% risk rate
    const costReduction = Math.round(hoursSaved * hourlyRate * 12);
    const processingMs = invoices * 0.3; // 300ms per invoice
    const processingTime = processingMs < 1000
      ? Math.round(processingMs) + 'ms'
      : processingMs < 60000
        ? (processingMs / 1000).toFixed(1) + 's'
        : (processingMs / 60000).toFixed(1) + 'min';

    // Animate results
    animateCounter(resultHours, hoursSaved, '', ' hrs');
    animateCounter(resultPenalty, penaltyRisk, '', ' SAR');
    animateCounter(resultCost, costReduction, '', ' SAR');
    if (resultSpeed) resultSpeed.textContent = processingTime;

    // Penalty card color transition
    if (penaltyCard) {
      penaltyCard.classList.add('calculated');
    }
  }

  function animateCounter(el, target, prefix, suffix) {
    if (!el) return;
    const current = parseInt(el.textContent.replace(/[^0-9-]/g, '')) || 0;
    const startTime = performance.now();
    const duration = 800;

    function update(now) {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const value = Math.floor(current + (target - current) * eased);
      el.textContent = prefix + value.toLocaleString() + suffix;

      if (progress < 1) requestAnimationFrame(update);
    }

    requestAnimationFrame(update);
  }

  // Event listeners
  [invoicesSlider, hoursSlider, valueSlider].forEach(slider => {
    slider.addEventListener('input', calculate);
  });

  // Initial calculation
  calculate();
}
