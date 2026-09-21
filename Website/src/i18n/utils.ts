import ar from './ar.json';
import en from './en.json';

const languages = {
  ar,
  en,
};

export function getLangFromUrl(url: URL) {
  const [, lang] = url.pathname.split('/');
  if (lang in languages) return lang as keyof typeof languages;
  return 'ar';
}

export function useTranslations(lang: keyof typeof languages) {
  return function t(key: keyof typeof ar) {
    return languages[lang][key] || languages['ar'][key];
  }
}
