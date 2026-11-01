// Файл проверки правил Firestore через API без создания книг и тестовых аккаунтов.

// Runs request-context tests, without creating books or test accounts.
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const project = process.argv[2]; // Берём Firebase project ID из аргумента команды.
if (!project) throw new Error('Pass the Firebase project id');
(async () => {
  const configPath = process.env.FIREBASE_TOOLS_CONFIG || path.join( // Находим файл действующей сессии Firebase CLI.
    process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config'), 'configstore/firebase-tools.json',
  );
  const token = JSON.parse(fs.readFileSync(configPath, 'utf8')).tokens.access_token; // Читаем токен CLI только для проверки правил, не выводя его.
  const testSuite = JSON.parse(fs.readFileSync('test/firestore_rules_cases.json', 'utf8')); // Читаем подготовленные сценарии доступа к Firestore.
  const res = await fetch(`https://firebaserules.googleapis.com/v1/projects/${project}:test`, { // Отправляем исходник правил и тестовые контексты в API проверки.
    method: 'POST', headers: {Authorization: `Bearer ${token}`, 'Content-Type': 'application/json'},
    body: JSON.stringify({source: {files: [{name: 'firestore.rules', content: fs.readFileSync('firestore.rules', 'utf8')}]}, testSuite}),
  });
  const data = await res.json(); // Разбираем ответ проверки правил.
  const results = data.testResults || []; // Отправляем исходник правил и тестовые контексты в API проверки.
  const failed = results.map((result, index) => ({index, ...result})).filter((result) => result.state !== 'SUCCESS'); // Находим проверки, которые завершились не так, как ожидалось.
  console.log(JSON.stringify({status: res.status, passed: results.length - failed.length, failed: failed.map(({index, state, debugMessages}) => ({index, state, debugMessages})), issues: data.issues, error: data.error})); // Выводим итоговые количества успешных и неуспешных проверок.
  fs.writeFileSync('/tmp/flutter-catalog-rules-results.json', JSON.stringify(data, null, 2)); // Сохраняем подробный отчёт проверки во временном каталоге.
  if (!res.ok || failed.length || results.length !== testSuite.testCases.length) process.exitCode = 1;
})().catch((error) => {console.error(error.message); process.exitCode = 1;}); // Если запрос не удался, показываем ошибку вместо закрытия приложения.
