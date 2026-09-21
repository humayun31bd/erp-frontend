<template>
  <div class="pricing-container">
    <div class="toggle-wrapper">
      <span :class="{ active: !isYearly }">{{ lang === 'ar' ? 'شهري' : 'Monthly' }}</span>
      <label class="switch">
        <input type="checkbox" v-model="isYearly">
        <span class="slider round"></span>
      </label>
      <span :class="{ active: isYearly }">
        {{ lang === 'ar' ? 'سنوي (وفر 20%)' : 'Yearly (Save 20%)' }}
      </span>
    </div>

    <div class="pricing-cards">
      <div class="card">
        <h3>{{ lang === 'ar' ? 'الباقة الأساسية' : 'Basic Plan' }}</h3>
        <div class="price">
          SAR {{ isYearly ? '199' : '249' }}
          <span>/ {{ lang === 'ar' ? 'شهر' : 'month' }}</span>
        </div>
        <button class="btn btn--primary">{{ lang === 'ar' ? 'اشترك الآن' : 'Subscribe Now' }}</button>
      </div>
      <div class="card premium">
        <h3>{{ lang === 'ar' ? 'باقة الوكالات' : 'Agency Plan' }}</h3>
        <div class="price">
          SAR {{ isYearly ? '499' : '599' }}
          <span>/ {{ lang === 'ar' ? 'شهر' : 'month' }}</span>
        </div>
        <button class="btn btn--secondary">{{ lang === 'ar' ? 'اشترك الآن' : 'Subscribe Now' }}</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

defineProps({
  lang: String
});

const isYearly = ref(true);
</script>

<style scoped>
.pricing-container {
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
}
.toggle-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 3rem;
  font-weight: bold;
}
.active {
  color: #2563eb;
}
.switch {
  position: relative;
  display: inline-block;
  width: 60px;
  height: 34px;
}
.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}
.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #cbd5e1;
  transition: .4s;
  border-radius: 34px;
}
.slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
}
input:checked + .slider {
  background-color: #2563eb;
}
input:checked + .slider:before {
  transform: translateX(26px);
}
.pricing-cards {
  display: flex;
  gap: 2rem;
  justify-content: center;
}
.card {
  background: white;
  padding: 3rem;
  border-radius: 1rem;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  flex: 1;
  max-width: 350px;
  border: 1px solid #e2e8f0;
}
.card.premium {
  border: 2px solid #2563eb;
  transform: scale(1.05);
}
.price {
  font-size: 2.5rem;
  font-weight: bold;
  margin: 1.5rem 0;
}
.price span {
  font-size: 1rem;
  color: #64748b;
}
</style>
