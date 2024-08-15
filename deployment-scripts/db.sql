CREATE TABLE file_translation_logs (
    file_name TEXT PRIMARY KEY,
    landing_zone_path TEXT,
    file_type TEXT CHECK (file_type IN ('pdf', 'docx')),
    upload_date DATE,
    upload_datetime TIMESTAMP,
    upload_status TEXT CHECK (upload_status IN ('failed', 'in progress', 'done')),
    translation_date DATE,
    translation_datetime TIMESTAMP,
    translation_status TEXT CHECK (translation_status IN ('failed', 'in progress', 'done')),
    translated_zone_path TEXT,
    fromLanguage TEXT,
    toLanguage TEXT,
    watermark_date DATE,
    watermark_datetime TIMESTAMP,
    watermark_status TEXT CHECK (watermark_status IN ('failed', 'in progress', 'done')),
    watermark_zone_path TEXT,
    glossary_content JSON,
    glossary_processing_status TEXT CHECK (glossary_processing_status IN ('failed', 'in progress', 'done')),
    glossary_zone_path TEXT,
    uploaded_by TEXT,
    exclusion_text TEXT,
    statue INTEGER,
    prompt_id INTEGER,
    additional_glossary_content_url TEXT
);

CREATE INDEX idx_file_name ON file_translation_logs (file_name);

CREATE TABLE prompt_logs (
    id SERIAL PRIMARY KEY,
    prompt_name TEXT,
    prompt_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_id ON prompt_logs (id);

INSERT INTO prompt_logs (prompt_name, prompt_text) VALUES (
    'Address Extraction',
    '- Extract all location addresses from the provided text. \n- Maintain the original address format. If the address spans multiple lines, keep it multiline. \n- Do not translate or modify the content. \n- Extract each line of the address in a separate line. \n- Provide only the extracted addresses without adding any additional text.\n'
);