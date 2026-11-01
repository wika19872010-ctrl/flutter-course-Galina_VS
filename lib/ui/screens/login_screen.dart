// Файл экрана входа и регистрации с полями email, пароля и сообщениями об ошибках.

import 'package:flutter/material.dart';

import '../../core/login_error_messages.dart';
import '../../data/login_service.dart';
import '../../data/nickname_store.dart';
import '../theme/app_styles.dart';

/// Показывает форму входа и регистрации по электронной почте и паролю.
class LoginScreen extends StatefulWidget {
  final LoginService login; // Храним сервис входа и регистрации.
  /// Принимает сервис, через который форма выполняет вход и регистрацию.
  const LoginScreen({super.key, required this.login});

  /// Создаёт объект состояния, который хранит изменяемые данные этого виджета.
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Хранит введённые данные, проверяет форму и показывает результат входа.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey =
      GlobalKey<FormState>(); // Храним ключ проверки формы авторизации.
  final _nickname = TextEditingController();
  final _email =
      TextEditingController(); // Запоминаем адрес, введённый в поле email.
  final _password =
      TextEditingController(); // Запоминаем пароль, введённый в поле.
  bool _register = false; // Выбираем между входом и созданием нового аккаунта.
  bool _busy = false; // Пока ждём ответа, не разрешаем повторную отправку.
  bool _hidePassword = true; // Сначала скрываем пароль точками.
  String? _error;

  /// Освобождает контроллеры при закрытии виджета, чтобы они больше не занимали ресурсы.
  @override
  void dispose() {
    _nickname.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Проверяем форму и выполняем вход либо регистрацию.
  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) {
      return; // Не отправляем форму повторно или с ошибками в полях.
    }
    FocusScope.of(context).unfocus();
    setState(() {
      // Обновляем поля и кнопки на этом экране.
      _busy = true;
      _error = null;
    });
    try {
      if (_register) {
        // При регистрации создаём аккаунт; иначе выполняем вход.
        await widget.login.register(
          _email.text.trim(),
          _password.text,
          _nickname.text.trim(),
        );
      } else {
        await widget.login.signIn(_email.text.trim(), _password.text);
      }
      // AuthGate сам откроет каталог после события Firebase.
    } catch (error) {
      // Если запрос не удался, показываем ошибку вместо закрытия приложения.
      if (mounted) {
        setState(
          () => _error = loginErrorMessage(error),
        ); // Обновляем экран, только если пользователь ещё не ушёл с него.
      }
    } finally {
      // Убираем признак ожидания и при успехе, и при ошибке.
      if (mounted) {
        setState(
          () => _busy = false,
        ); // Обновляем экран, только если пользователь ещё не ушёл с него.
      }
    }
  }

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Выбираем цвет фона.
      appBar: AppBar(
        // Создаём верхнюю панель экрана.
        backgroundColor: AppColors.surface, // Выбираем цвет фона.
        title: Text(_register ? 'Регистрация' : 'Вход в каталог книг'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                .onDrag, // Разрешаем скрывать системную клавиатуру прокруткой.
            padding: const EdgeInsets.all(24), // Создаём отступы внутри блока.
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ), // Ограничиваем размер содержимого.
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_register) ...[
                      TextFormField(
                        key: const ValueKey('nickname'),
                        controller: _nickname,
                        enabled: !_busy,
                        maxLength: 30,
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.nickname],
                        decoration: const InputDecoration(
                          labelText: 'Никнейм',
                          border: OutlineInputBorder(),
                        ),
                        // Проверяем формат до обращения к Firebase; занятость проверяет сервер.
                        validator: (value) => nicknameError(value ?? ''),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      // Создаём проверяемое поле формы.
                      onTapOutside:
                          (_) => // При нажатии вне поля завершаем ввод и скрываем клавиатуру.
                              FocusManager.instance.primaryFocus?.unfocus(),
                      controller: _email, // Запоминаем введённый текст, чтобы использовать его при сохранении.
                      enabled: !_busy, // Управляем доступностью поля во время запроса.
                      keyboardType: TextInputType.emailAddress, // Выбираем удобную клавиатуру; ввод с физической клавиатуры тоже работает.
                      textInputAction: TextInputAction.next, // Задаём действие клавиши подтверждения на клавиатуре.
                      autocorrect:
                          false, // Настраиваем исправление вводимого текста.
                      autofillHints: const [
                        AutofillHints.email,
                      ], // Подсказываем системе тип данных для автозаполнения.
                      decoration: const InputDecoration(
                        // Оформляем фон и рамку.
                        labelText: 'Email', // Задаём подпись поля.
                        border:
                            OutlineInputBorder(), // Настраиваем рамку элемента.
                      ),
                      validator: (value) {
                        // Проверяем введённое значение до запроса.
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Введите email.';
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(email)) {
                          return 'Введите корректный email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ), // Оставляем промежуток между соседними элементами.
                    TextFormField(
                      // Создаём проверяемое поле формы.
                      onTapOutside:
                          (_) => // При нажатии вне поля завершаем ввод и скрываем клавиатуру.
                              FocusManager.instance.primaryFocus?.unfocus(),
                      controller: _password, // Запоминаем введённый текст, чтобы использовать его при сохранении.
                      keyboardType: TextInputType.visiblePassword, // Выбираем удобную клавиатуру; ввод с физической клавиатуры тоже работает.
                      enabled: !_busy, // Управляем доступностью поля во время запроса.
                      obscureText:
                          _hidePassword, // Управляем скрытием символов пароля.
                      autocorrect:
                          false, // Настраиваем исправление вводимого текста.
                      enableSuggestions:
                          false, // Настраиваем подсказки клавиатуры.
                      autofillHints: [
                        // Подсказываем системе тип данных для автозаполнения.
                        _register
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      onFieldSubmitted: (_) => _submit(), // Проверяем форму и выполняем вход либо регистрацию.
                      decoration: InputDecoration(
                        // Оформляем фон и рамку.
                        labelText: 'Пароль', // Задаём подпись поля.
                        border: const OutlineInputBorder(), // Настраиваем рамку элемента.
                        suffixIcon: IconButton(
                          // Добавляем действие справа от поля.
                          tooltip:
                              _hidePassword // Поясняем назначение кнопки при долгом нажатии.
                              ? 'Показать пароль'
                              : 'Скрыть пароль',
                          onPressed: _busy
                              ? null
                              : () => setState(
                                  // Обновляем поля и кнопки на этом экране.
                                  () => _hidePassword = !_hidePassword,
                                ),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        // Проверяем введённое значение до запроса.
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль.';
                        }
                        if (_register && value.length < 6) {
                          return 'Пароль должен содержать не менее 6 символов.';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(
                        height: 16,
                      ), // Оставляем промежуток между соседними элементами.
                      Text(
                        _error!,
                        style: TextStyle(
                          // Выбираем оформление текста.
                          color: Theme.of(context).colorScheme.error,
                        ),
                        semanticsLabel: _error,
                      ),
                    ],
                    const SizedBox(
                      height: 24,
                    ), // Оставляем промежуток между соседними элементами.
                    FilledButton(
                      // Создаём кнопку с цветным фоном.
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              // Оставляем промежуток между соседними элементами.
                              width: 20, // Задаём ширину элемента.
                              height: 20, // Задаём высоту элемента.
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_register ? 'Зарегистрироваться' : 'Войти'),
                    ),
                    TextButton(
                      // Создаём кнопку с надписью.
                      onPressed: _busy
                          ? null
                          : () {
                              setState(() {
                                // Обновляем поля и кнопки на этом экране.
                                _register = !_register;
                                _error = null;
                                _password.clear();
                                _formKey.currentState?.reset();
                              });
                            },
                      child: Text(
                        _register
                            ? 'Уже есть аккаунт? Войти'
                            : 'Нет аккаунта? Зарегистрироваться',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
