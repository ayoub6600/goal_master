import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const source = fs.readFileSync('lib/features/card/presentation/view/widgets/card_fill_script.dart', 'utf8');
const start = source.indexOf("const _script = r'''") + "const _script = r'''".length;
const end = source.indexOf("''';", start);
assert(start >= 0 && end > start, 'production frame script must be present');
const script = source.slice(start, end).replace('__ALLOWED_ORIGINS__', JSON.stringify(['https://npg.moamalat.net:6006']));

function mockFrame(origin = 'https://npg.moamalat.net:6006', { withName = true } = {}) {
  const events = [];
  const form = { submissions: 0, querySelectorAll(selector) { return selector === 'input[type="checkbox"]' ? checks : []; } };
  class Input {
    constructor(id, autocomplete, label, formRef = form) {
      this.id = id; this.name = id; this.autocomplete = autocomplete; this.placeholder = '';
      this.type = 'text'; this.disabled = false; this.readOnly = false; this.form = formRef;
      this.labels = [{ textContent: label }]; this.value = ''; this.events = []; this.checked = false;
    }
    getAttribute(key) { return ({ autocomplete: this.autocomplete, maxlength: '24', 'aria-label': '' })[key] ?? null; }
    getBoundingClientRect() { return { width: 160, height: 30 }; }
    compareDocumentPosition(other) { return fields.indexOf(this) < fields.indexOf(other) ? 4 : 0; }
    dispatchEvent(event) { this.events.push(event.type); return true; }
    focus() {}
    blur() {}
    click() { this.checked = !this.checked; this.events.push('click'); }
  }
  Object.defineProperty(Input.prototype, 'value', {
    get() { return this._value ?? ''; },
    set(value) { this._value = String(value); },
    configurable: true,
  });
  const fields = [
    new Input('card-number', 'cc-number', 'Card number'),
    new Input('card-expiry', 'cc-exp', 'Expiry date'),
    new Input('card-cvv', 'cc-csc', 'Security code'),
    ...(withName ? [new Input('card-name', 'cc-name', 'Name on card')] : []),
  ];
  const checks = [new Input('accept-terms', '', 'I agree to the payment terms'), new Input('save-card', '', 'Remember this card')];
  for (const check of checks) { check.type = 'checkbox'; check.getAttribute = key => key === 'type' ? 'checkbox' : null; }
  form.querySelectorAll = selector => selector === 'input[type="checkbox"]' ? checks : [];
  for (const field of fields) field.form = form;
  const posted = [];
  class MockInputEvent { constructor(type) { this.type = type; } }
  class MockEvent { constructor(type) { this.type = type; } }
  class MockMutationObserver { observe() {} }
  const window = {
    location: { origin },
    webkit: { messageHandlers: { goalMasterCardFill: { postMessage: message => posted.push(message) } } },
    setTimeout,
  };
  const document = {
    readyState: 'complete',
    documentElement: {},
    body: {},
    querySelectorAll: selector => selector === 'input' ? [...fields, ...checks] : [],
    addEventListener() {},
  };
  const context = {
    window, document, Node: { DOCUMENT_POSITION_FOLLOWING: 4 },
    HTMLInputElement: Input, InputEvent: MockInputEvent, Event: MockEvent,
    MutationObserver: MockMutationObserver, getComputedStyle: () => ({ display: 'block', visibility: 'visible' }),
    addEventListener() {}, setTimeout,
  };
  vm.runInNewContext(script, context);
  return { window, fields, checks, form, posted };
}

{
  const mock = mockFrame('https://evil.example');
  assert.equal(mock.window.__goalMasterFill, undefined, 'unapproved frame must receive no fill entry point');
  assert.equal(mock.posted.length, 0, 'unapproved frame must not signal readiness');
}

{
  const mock = mockFrame();
  assert.equal(mock.posted[0].type, 'ready', 'approved mock iframe should report a recognized form');
  const [pan, expiry, cvv, name] = mock.fields;
  const result = await mock.window.__goalMasterFill({ pan: '4111111111111111', exp: '12/30', name: 'TEST CARDHOLDER', acceptTerms: true });
  assert.equal(result.ok, true);
  assert.equal(result.pan, 'filled');
  assert.equal(result.exp, 'filled');
  assert.equal(result.name, 'filled');
  assert.equal(result.terms, 'checked');
  assert.equal(result.cvv, 'untouched');
  assert.equal(pan.value, '4111111111111111');
  assert.equal(expiry.value, '1230');
  assert.equal(name.value, 'TEST CARDHOLDER');
  assert.equal(cvv.value, '');
  assert.equal(mock.checks[0].checked, true);
  assert.equal(mock.checks[1].checked, false, 'save-card checkbox must never be touched');
  assert.equal(mock.form.submissions, 0, 'no payment form submit');
  assert.equal(mock.fields.some(field => field.events.includes('input') && field.events.includes('change')), true);
}

{
  const mock = mockFrame();
  const result = await mock.window.__goalMasterFill({ pan: '4111111111111111', exp: '12/30', name: 'TEST CARDHOLDER', acceptTerms: false });
  assert.equal(result.ok, true);
  assert.equal(result.terms, 'skipped');
  assert.equal(mock.checks[0].checked, false, 'terms require explicit consent');
}

{
  const mock = mockFrame('https://npg.moamalat.net:6006', { withName: false });
  assert.equal(mock.posted[0].type, 'gone', 'unsupported field shape must fail closed');
  const result = await mock.window.__goalMasterFill({ pan: '4111111111111111', exp: '12/30', name: 'TEST CARDHOLDER', acceptTerms: true });
  assert.equal(result.ok, false);
  assert.equal(result.reason, 'unknown_form');
  assert.equal(mock.checks[0].checked, false, 'unknown forms must never be changed');
}
console.log('Smart Fill mock-frame checks passed (synthetic data only).');
