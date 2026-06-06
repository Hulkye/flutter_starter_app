import 'package:flutter_starter_app/header.dart';
import '../viewmodels/auth_viewmodel.dart';

/// 登录页（模板演示）。
class LoginPage extends BasePage {
  LoginPage({super.key});

  final _accountCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // ── UI ──

  @override
  bool get showAppBar => false;
  @override
  bool? get resizeToAvoidBottomInset => true;

  @override
  void onPageClose(PageScope scope) {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
  }

  Widget _createInputWidget(
    PageScope scope, {
    required TextEditingController ctrl,
    required IconData icon,
    bool obscureText = false,
    String? hintText,
    ValueChanged<String?>? onChanged,
    ValueChanged<String?>? onSubmitted,
  }) {
    return InputWidget(
      controller: ctrl,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      icon: Padding(
        padding: EdgeInsets.all(12.w),
        child: Icon(
          icon,
          color: scope.context.appColor.iconSecondary,
          size: 18.w,
        ),
      ),
      decoratedInput: (context, input) {
        return Container(
          height: 46.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.w)),
            color: context.appColor.backgroundSecondary,
          ),
          child: input,
        );
      },
      obscureText: obscureText,
      hintText: hintText,
      enabled: scope.ref.watch(authViewModelProvider).isLoading == false,
    );
  }

  Widget _accountInput(PageScope scope) {
    Widget child = _createInputWidget(
      scope,
      ctrl: _accountCtrl,
      icon: Icons.person_outline,
      hintText: '请输入账号',
      onChanged: scope.ref.read(authViewModelProvider.notifier).updateAccount,
    );
    return child;
  }

  Widget _passwordInput(PageScope scope) {
    Widget child = _createInputWidget(
      scope,
      ctrl: _passwordCtrl,
      icon: Icons.lock_outline,
      obscureText: true,
      hintText: '请输入密码',
      onChanged: scope.ref.read(authViewModelProvider.notifier).updatePassword,
      onSubmitted: (_) =>
          _login(scope, scope.ref.read(authViewModelProvider.notifier)),
    );
    return child;
  }

  @override
  Widget page(PageScope scope) {
    final ref = scope.ref;
    final vm = ref.read(authViewModelProvider.notifier);
    final state = ref.watch(authViewModelProvider);
    final session = ref.watch(authSessionProvider);
    final isLoggedIn = session?.isValid == true;

    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appRouterProvider).replaceAll(const HomeRoute().location);
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final appColor = context.appColor;
        final appAsset = context.appAsset;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LogoSection(assetPath: appAsset.logo),
                    const SizedBox(height: 40),
                    _accountInput(scope),
                    const SizedBox(height: 18),
                    _passwordInput(scope),
                    const SizedBox(height: 32),
                    PrimaryRoundButton(
                      context: context,
                      label: state.isLoading
                          ? context.i18n.requesting
                          : context.i18n.login,
                      onPressed: state.isLoading
                          ? null
                          : () => _login(scope, vm),
                      expand: true,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.i18n.appTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appColor.fontTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _login(PageScope scope, AuthViewModel vm) async {
    await vm.login(_accountCtrl.text.trim(), _passwordCtrl.text.trim());
    if (scope.ref.read(authSessionProvider)?.isValid == true) {
      scope.ref.read(appRouterProvider).replaceAll(const HomeRoute().location);
    }
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final appColor = context.appColor;

    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: appColor.compBackgroundSecondary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.flutter_dash, size: 54, color: appColor.brand);
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.i18n.login,
          style: TextStyle(
            color: appColor.fontPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
