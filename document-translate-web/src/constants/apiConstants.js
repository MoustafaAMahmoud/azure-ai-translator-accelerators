export const API_KEY = "75a2bc4375b244159e0505563e322d4d"; // Replace with your API key
export const BASE_URL = "https://translator-apim-duwih.azure-api.net/translation-service"; // Replace with your API Management URL
export const GET_LOGS_API = (date) => `${BASE_URL}/get_logs_by_date?date=${date}`;
export const GET_ALL_LOGS = `${BASE_URL}/get_all_logs`;
export const UPLOAD_API = `${BASE_URL}/upload_file`;
export const GET_PROMPTS_API = `${BASE_URL}/get_all_prompts`;
