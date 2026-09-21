<template>
  <div class="faq-container">
    <div v-for="(item, index) in faqs" :key="index" class="faq-item">
      <button class="faq-question" @click="toggle(index)">
        {{ item.q }}
        <span class="icon">{{ activeIndex === index ? '−' : '+' }}</span>
      </button>
      <div v-show="activeIndex === index" class="faq-answer">
        {{ item.a }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  lang: String
});

const activeIndex = ref(null);

const toggle = (index) => {
  activeIndex.value = activeIndex.value === index ? null : index;
};

const faqsAr = [
  { q: 'هل النظام معتمد من هيئة الزكاة (ZATCA)؟', a: 'نعم، النظام معتمد بالكامل وجاهز للمرحلة الثانية للربط والتكامل.' },
  { q: 'كم يستغرق ربط النظام؟', a: 'يمكن للوكالات ربط عملائهم في أقل من 15 دقيقة بفضل واجهة API السهلة.' },
  { q: 'هل يدعم إرسال الفواتير عبر الواتساب؟', a: 'نعم، النظام يرسل الفاتورة تلقائياً عبر الواتساب بمجرد إصدارها.' }
];

const faqsEn = [
  { q: 'Is the system ZATCA approved?', a: 'Yes, the system is fully approved and Phase 2 Integration ready.' },
  { q: 'How long does integration take?', a: 'Agencies can onboard clients in less than 15 minutes using our simple API.' },
  { q: 'Does it support WhatsApp invoicing?', a: 'Yes, invoices are automatically sent via WhatsApp upon issuance.' }
];

const faqs = computed(() => props.lang === 'ar' ? faqsAr : faqsEn);
</script>

<style scoped>
.faq-container {
  max-width: 800px;
  margin: 0 auto;
}
.faq-item {
  border-bottom: 1px solid #e2e8f0;
  padding: 1rem 0;
}
.faq-question {
  width: 100%;
  text-align: inherit;
  background: none;
  border: none;
  font-size: 1.125rem;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #0f172a;
}
.faq-answer {
  padding-top: 1rem;
  color: #475569;
  line-height: 1.6;
}
.icon {
  font-size: 1.5rem;
  color: #2563eb;
}
</style>
