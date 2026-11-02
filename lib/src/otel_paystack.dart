// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_paystack_suppression.dart';

const _tracerName = 'dartastic_otel_libs_paystack';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class PaystackResult {
  /// Creates a result.
  const PaystackResult({
    this.environment,
    this.reference,
    this.amountSubunits,
    this.currency,
    this.country,
    this.channel,
    this.cardNetwork,
    this.cardBin,
    this.cardLast4,
    this.cardAuthorizationCode,
    this.cardReusable,
    this.bankCode,
    this.transferRecipientCode,
    this.transactionStatus,
    this.gatewayResponse,
    this.feesSubunits,
    this.subaccountCode,
    this.planCode,
    this.subscriptionCode,
    this.subscriptionStatus,
    this.errorCode,
    this.statusCode,
  });

  /// `test` / `live`.
  final String? environment;

  /// Paystack transaction reference.
  final String? reference;

  /// Amount in kobo / cents (smallest currency unit).
  final int? amountSubunits;

  /// ISO 4217: `NGN`, `GHS`, `KES`, `ZAR`, `USD`.
  final String? currency;

  /// ISO 3166: `NG`, `GH`, `KE`, `ZA`.
  final String? country;

  /// `card`, `bank`, `ussd`, `qr`, `mobile_money`, `bank_transfer`,
  /// `apple_pay`, `eft`.
  final String? channel;

  /// `visa`, `mastercard`, `verve`.
  final String? cardNetwork;
  final String? cardBin;
  final String? cardLast4;

  /// `AUTH_xxxx` — reusable authorization for charging customer again.
  final String? cardAuthorizationCode;

  /// Authorization marked reusable for future charges.
  final bool? cardReusable;

  /// CBN bank code for transfers / direct debit.
  final String? bankCode;

  /// `RCP_xxxx` transfer recipient code.
  final String? transferRecipientCode;

  /// `success`, `failed`, `abandoned`, `pending`, `reversed`,
  /// `processing`, `queued`, `ongoing`.
  final String? transactionStatus;

  /// Processor gateway response message
  /// (`Successful`, `Approved`, `Declined`, `Insufficient Funds`, ...).
  final String? gatewayResponse;

  /// Paystack fee component in subunits.
  final int? feesSubunits;

  /// Split / Marketplace subaccount.
  final String? subaccountCode;

  final String? planCode;
  final String? subscriptionCode;

  /// `active`, `attention`, `non-renewing`, `cancelled`, `completed`.
  final String? subscriptionStatus;

  /// `invalid_request`, `authentication_failed`, `card_declined`,
  /// `transaction_not_found`, `duplicate_request`, `processor_unreachable`.
  final String? errorCode;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class PaystackCallResult<T> {
  /// Creates a call result.
  const PaystackCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final PaystackResult? result;
}

/// Wraps a Paystack call in a CLIENT span. [operation] is one of
/// `chargeCard`, `chargeAuthorization`, `chargeBankAccount`,
/// `initializeTransaction`, `verifyTransaction`, `fetchTransaction`,
/// `listTransactions`, `refundTransaction`, `submitOtp`, `submitPin`,
/// `submitPhone`, `submitBirthday`, `submitAddress`,
/// `createTransferRecipient`, `initiateTransfer`, `verifyTransfer`,
/// `createPlan`, `listPlans`, `createSubscription`, `disableSubscription`,
/// `enableSubscription`, `chargeUssd`, `chargeMobileMoney`,
/// `resolveBank`, `resolveCard`, `bvnMatch`.
Future<T> tracedPaystack<T>({
  required String operation,
  required Future<PaystackCallResult<T>> Function() invoke,
}) async {
  if (paystackInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'paystack',
    'rpc.method': operation,
    'paystack.operation': operation,
  };

  final span = _tracer().startSpan(
    'paystack $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.environment != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.environment',
          res.environment!,
        ));
      }
      if (res.reference != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.reference',
          res.reference!,
        ));
      }
      if (res.amountSubunits != null) {
        extras.add(OTelAPI.attributeInt(
          'paystack.amount.subunits',
          res.amountSubunits!,
        ));
      }
      if (res.currency != null) {
        extras.add(OTelAPI.attributeString('paystack.currency', res.currency!));
      }
      if (res.country != null) {
        extras.add(OTelAPI.attributeString('paystack.country', res.country!));
      }
      if (res.channel != null) {
        extras.add(OTelAPI.attributeString('paystack.channel', res.channel!));
      }
      if (res.cardNetwork != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.card.network',
          res.cardNetwork!,
        ));
      }
      if (res.cardBin != null) {
        extras.add(OTelAPI.attributeString('paystack.card.bin', res.cardBin!));
      }
      if (res.cardLast4 != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.card.last4',
          res.cardLast4!,
        ));
      }
      if (res.cardAuthorizationCode != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.card.authorization_code',
          res.cardAuthorizationCode!,
        ));
      }
      if (res.cardReusable != null) {
        extras.add(OTelAPI.attributeBool(
          'paystack.card.reusable',
          res.cardReusable!,
        ));
      }
      if (res.bankCode != null) {
        extras
            .add(OTelAPI.attributeString('paystack.bank.code', res.bankCode!));
      }
      if (res.transferRecipientCode != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.transfer.recipient_code',
          res.transferRecipientCode!,
        ));
      }
      if (res.transactionStatus != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.transaction.status',
          res.transactionStatus!,
        ));
        if (res.transactionStatus == 'failed' ||
            res.transactionStatus == 'reversed') {
          span.setStatus(
            SpanStatusCode.Error,
            'Paystack transaction ${res.transactionStatus}',
          );
        }
      }
      if (res.gatewayResponse != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.gateway.response',
          res.gatewayResponse!,
        ));
      }
      if (res.feesSubunits != null) {
        extras.add(OTelAPI.attributeInt(
          'paystack.fees.subunits',
          res.feesSubunits!,
        ));
      }
      if (res.subaccountCode != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.subaccount.code',
          res.subaccountCode!,
        ));
      }
      if (res.planCode != null) {
        extras
            .add(OTelAPI.attributeString('paystack.plan.code', res.planCode!));
      }
      if (res.subscriptionCode != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.subscription.code',
          res.subscriptionCode!,
        ));
      }
      if (res.subscriptionStatus != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.subscription.status',
          res.subscriptionStatus!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'paystack.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Paystack ${res.errorCode}');
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Paystack HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
