const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const I18N_DIR = path.join(ROOT, 'tools', 'i18n');
const overrides = require('./iap_i18n_overrides');

const REMOVE_KEYS = [
  'iap_lifetime_price',
  'iap_yearly_price',
  'iap_yearly_per_week',
  'iap_trial_subtitle',
  'iap_weekly_price',
  'iap_restore_purchases',
];

for (const [locale, strings] of Object.entries(overrides)) {
  const filePath = path.join(I18N_DIR, `${locale}.json`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

  for (const key of REMOVE_KEYS) {
    delete data[key];
  }

  Object.assign(data, strings);

  const sorted = Object.fromEntries(
    Object.keys(data)
      .sort()
      .map((k) => [k, data[k]]),
  );

  fs.writeFileSync(filePath, JSON.stringify(sorted, null, 2) + '\n', 'utf8');
  console.log(`Updated ${locale}`);
}

console.log('Done. Run: node tools/generate_i18n.js');
