import 'dart:async';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/auth/sign_up/service/verify_email_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const int _kOtpLength = 6;
const int _kResendCooldown = 60; // seconds
const int _kOtpExpiry = 10 * 60; // 10 minutes

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  /// Called after successful verification — caller decides where to navigate.
  final VoidCallback onVerified;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(
    _kOtpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _kOtpLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  bool _success = false;
  String _error = '';

  int _resendTimer = _kResendCooldown;
  int _expiryTimer = _kOtpExpiry;

  Timer? _resendTick;
  Timer? _expiryTick;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startExpiryTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTick?.cancel();
    _expiryTick?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTick?.cancel();
    setState(() => _resendTimer = _kResendCooldown);
    _resendTick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _startExpiryTimer() {
    _expiryTick?.cancel();
    setState(() => _expiryTimer = _kOtpExpiry);
    _expiryTick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_expiryTimer > 0) {
          _expiryTimer--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String _formatTime(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _otpComplete => _otp.length == _kOtpLength;

  void _onDigitChanged(int index, String value) {
    final digit = value.replaceAll(RegExp(r'\D'), '');
    if (digit.isEmpty) return;

    _controllers[index].text = digit[digit.length - 1];
    setState(() => _error = '');

    if (index < _kOtpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
      if (_otpComplete) _verify();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      } else {
        _controllers[index].clear();
      }
      setState(() {});
    }
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  Future<void> _verify() async {
    if (!_otpComplete) {
      setState(() => _error = 'Please enter the complete 6-digit OTP.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await VerifyEmailAuthService.verifyEmail(
      email: widget.email,
      otp: _otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) widget.onVerified();
    } else {
      final code = result['code'] as String?;
      setState(() {
        _error = code == 'OTP_EXPIRED'
            ? 'Your OTP has expired. Please request a new one.'
            : (result['message'] ?? 'Verification failed. Please try again.');
      });
      _clearOtp();
    }
  }

  Future<void> _resend() async {
    if (_resendTimer > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _error = '';
    });

    final result = await VerifyEmailAuthService.resendOtp(email: widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (result['success'] == true) {
      _clearOtp();
      _startResendTimer();
      _startExpiryTimer();
    } else {
      setState(() => _error = result['message'] ?? 'Failed to resend OTP.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Email',
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _success
            ? _buildSuccessView(colorScheme)
            : _buildForm(colorScheme, primary),
      ),
    );
  }

  Widget _buildSuccessView(ColorScheme cs) {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: cs.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Email Verified!',
              style: AppTextStyles.midHeader(
                context,
              ).copyWith(color: cs.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Redirecting you to your dashboard...',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ColorScheme cs, Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.shield_outlined, color: primary, size: 36),
          ),
          const SizedBox(height: 20),

          Text(
            'Verify your email',
            style: AppTextStyles.midHeader(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'We sent a 6-digit code to\n'),
                TextSpan(
                  text: widget.email,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Error
          if (_error.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // OTP Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_kOtpLength, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (e) => _onKeyEvent(i, e),
                  child: SizedBox(
                    width: 48,
                    height: 58,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      autofocus: i == 0,
                      enabled: !_isLoading,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength:
                          2, // allow 2 so we catch paste → take last char
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _controllers[i].text.isNotEmpty
                            ? primary.withValues(alpha: 0.06)
                            : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _controllers[i].text.isNotEmpty
                                ? primary
                                : cs.outlineVariant,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Expiry timer
          if (_expiryTimer > 0)
            Text(
              'Code expires in ${_formatTime(_expiryTimer)}',
              style: TextStyle(
                fontSize: 13,
                color: _expiryTimer < 120 ? Colors.orange : cs.onSurfaceVariant,
              ),
            )
          else
            Text(
              'Code expired. Please request a new one.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 28),

          // Verify Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading || !_otpComplete ? null : _verify,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Verify Email', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),

          // Resend
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: _resendTimer > 0 || _isResending ? null : _resend,
                icon: _isResending
                    ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: primary,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 14),
                label: Text(
                  _isResending
                      ? 'Sending...'
                      : _resendTimer > 0
                      ? 'Resend in ${_resendTimer}s'
                      : 'Resend OTP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
