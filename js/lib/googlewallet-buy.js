/**
 * Stub for Google Wallet / Google Play In-App Billing.
 * The original connected to Chrome extension nmmhkkegccagdldgiimedpiccmgmieda.
 * ga.me backend is shutdown - payments are defunct. This stub prevents crashes.
 */
(function () {
    'use strict';

    window.google = window.google || {};
    window.google.payments = window.google.payments || {};
    window.google.payments.inapp = window.google.payments.inapp || {};
    window.google.payments.inapp.buy = function (request) {
        if (request && request.failure) {
            request.failure({
                request: {},
                response: { errorType: 'SERVICE_UNAVAILABLE' }
            });
        }
    };
})();
