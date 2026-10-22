import 'dart:convert';

const moamalatCardOrigins = <String>['https://npg.moamalat.net:6006'];

String buildMoamalatCardFillScript(
        {List<String> origins = moamalatCardOrigins}) =>
    _script.replaceFirst(
      '__ALLOWED_ORIGINS__',
      jsonEncode(origins),
    );

const _script = r'''(() => {
  'use strict';
  const allowed = __ALLOWED_ORIGINS__;
  const origin = window.location.origin;
  if (!allowed.includes(origin)) return;

  const visible = e => {
    const r = e.getBoundingClientRect(), s = getComputedStyle(e);
    return r.width > 4 && r.height > 4 && s.display !== 'none' && s.visibility !== 'hidden' && !e.disabled && !e.readOnly;
  };
  const signature = e => [e.id, e.name, e.placeholder, e.getAttribute('aria-label'),
    ...(e.labels ? Array.from(e.labels, l => l.textContent) : [])].join(' ').toLowerCase();
  const choose = (inputs, auto, pattern) => {
    const byAuto = inputs.filter(e => (e.autocomplete || '').toLowerCase() === auto);
    const matches = byAuto.length ? byAuto : inputs.filter(e => pattern.test(signature(e)));
    return matches.length === 1 ? matches[0] : null;
  };
  const scan = () => {
    const inputs = Array.from(document.querySelectorAll('input')).filter(visible);
    const pan = choose(inputs, 'cc-number', /card\s*-?\s*(number|no)|cc-?num|رقم\s*البطاقة/);
    const exp = choose(inputs, 'cc-exp', /expir|\bexp\b|mm\s*\/\s*yy|انتهاء|الصلاحية/);
    const cvv = choose(inputs, 'cc-csc', /cvv|cvc|csc|security\s*code|رمز\s*الأمان/);
    const name = choose(inputs, 'cc-name', /name\s*on\s*card|card\s*-?\s*holder|holder|اسم\s*حامل|الاسم\s*على\s*البطاقة/);
    if (!pan || !exp || !cvv || !name || !pan.form || pan.form !== exp.form || exp.form !== cvv.form || cvv.form !== name.form) return null;
    if (!(pan.compareDocumentPosition(exp) & Node.DOCUMENT_POSITION_FOLLOWING) || !(exp.compareDocumentPosition(cvv) & Node.DOCUMENT_POSITION_FOLLOWING)) return null;
    return { form: pan.form, pan, exp, cvv, name };
  };
  const post = value => {
    try {
      if (window.webkit?.messageHandlers?.goalMasterCardFill) window.webkit.messageHandlers.goalMasterCardFill.postMessage(value);
      else window.goalMasterCardFill?.postMessage(JSON.stringify(value));
    } catch (_) {}
  };
  const state = scan() ? 'ready' : 'gone';
  post({ type: state, origin });
  const setValue = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
  const digits = value => String(value || '').replace(/\D/g, '');
  const termsMatches = form => Array.from(form.querySelectorAll('input[type="checkbox"]')).filter(box => {
    if (box.disabled) return false;
    const text = [box.id, box.name, box.getAttribute('aria-label'), ...(box.labels ? Array.from(box.labels, l => l.textContent) : [])].join(' ').toLowerCase();
    return /payment\s*terms|terms|conditions|agree|accept|شروط\s*الدفع|الشروط|الأحكام|الاحكام|أوافق|اوافق/.test(text) && !/save|remember|حفظ|تذكر/.test(text);
  });
  const fill = async ({ pan, exp, name, acceptTerms }) => {
    let f = scan();
    if (!f || origin !== window.location.origin || !allowed.includes(origin)) return { ok: false, reason: 'unknown_form', pan: 'failed', exp: 'failed', name: 'failed', terms: 'skipped' };
    if (f.cvv.value !== '') return { ok: false, reason: 'cvv_not_empty', pan: 'failed', exp: 'failed', name: 'failed', terms: 'skipped' };
    const cvvWasEmpty = true;
    const values = { pan: digits(pan), exp: digits(exp), name: String(name || '').trim() };
    if (values.pan.length < 12 || values.pan.length > 19 || values.exp.length !== 4 || !values.name) return { ok: false, reason: 'invalid_card', pan: 'failed', exp: 'failed', name: 'failed', terms: 'skipped' };
    for (const [field, value] of [[f.pan, values.pan], [f.exp, values.exp], [f.name, values.name]]) {
      field.focus(); setValue.call(field, value);
      field.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText', data: value }));
      field.dispatchEvent(new Event('change', { bubbles: true })); field.blur();
    }
    let terms = 'skipped';
    if (acceptTerms === true) {
      const boxes = termsMatches(f.form);
      if (boxes.length === 1) {
        if (!boxes[0].checked) boxes[0].click();
        terms = boxes[0].checked ? 'checked' : 'failed';
      } else terms = boxes.length ? 'failed' : 'absent';
    }
    await new Promise(resolve => setTimeout(resolve, 250));
    f = scan() || f;
    const result = {
      pan: digits(f.pan.value) === values.pan ? 'filled' : 'failed',
      exp: digits(f.exp.value) === values.exp ? 'filled' : 'failed',
      name: f.name.value.trim() === values.name ? 'filled' : 'failed',
      terms,
      cvv: cvvWasEmpty && f.cvv.value === '' ? 'untouched' : 'failed',
    };
    result.ok = result.pan === 'filled' && result.exp === 'filled' && result.name === 'filled' && result.cvv === 'untouched' && (terms !== 'failed');
    return result;
  };
  if (window.goalMasterCardFill?.addEventListener) {
    window.goalMasterCardFill.addEventListener('message', event => {
      let data; try { data = JSON.parse(event.data); } catch (_) { return; }
      if (data?.op !== 'fill') return;
      const pending = fill(data); data = null;
      pending.then(result => post({ type: 'result', result }));
    });
  }
  Object.defineProperty(window, '__goalMasterFill', { value: fill, configurable: false });
  const start = () => {
    const root = document.documentElement;
    if (!root) return;
    let last = null;
    const report = () => { const next = scan() ? 'ready' : 'gone'; if (next !== last) { last = next; post({ type: next, origin }); } };
    report();
    new MutationObserver(report).observe(root, { childList: true, subtree: true, attributes: true, attributeFilter: ['style', 'class', 'hidden', 'disabled'] });
    addEventListener('pagehide', () => post({ type: 'gone', origin }));
  };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, { once: true }); else start();
})();''';
