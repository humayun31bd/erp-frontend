<template>
  <div class="lang-switcher">
    <button @click="switchLanguage" class="btn-lang">
      {{ currentLang === 'ar' ? 'English' : 'العربية' }}
    </button>
  </div>
</template>

<script setup>
const props = defineProps({
  currentLang: {
    type: String,
    required: true
  }
});

const switchLanguage = () => {
  const newLang = props.currentLang === 'ar' ? 'en' : 'ar';
  window.location.href = `/${newLang}/`;
};
</script>

<style scoped>
.lang-switcher {
  position: absolute;
  top: 1rem;
  right: 1rem;
}
.btn-lang {
  background: transparent;
  border: 1px solid #cbd5e1;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  cursor: pointer;
  font-family: inherit;
}
.btn-lang:hover {
  background: #f1f5f9;
}
html[dir="rtl"] .lang-switcher {
  right: auto;
  left: 1rem;
}
</style>
