import { languageOptions } from "../constants/languageConstants";

export const getLanguageByCode = (code) => {
  const language = languageOptions.find((lang) => lang.value === code);
  
  if (language) {
    return language.label;
  } else {
    console.error(`Language not found for code: ${code}`);
    return 'Unknown'; // Default label if not found
  }
};
