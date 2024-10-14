export const API_KEY = ""; // This is the API key for the Azure API
export const BASE_URL = "https://tf-ai-translator-dev-apim-mvyr.azure-api.net/translation-service"; // This is the base URL for the Azure API
export const GET_LOGS_API = (date) => `${BASE_URL}/get_logs_by_date?date=${date}`;
export const GET_ALL_LOGS = `${BASE_URL}/get_all_logs`;
export const UPLOAD_API = `${BASE_URL}/upload_file`;
export const GET_PROMPTS_API = `${BASE_URL}/get_all_prompts`;
