// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_paystack_suppression.dart';

const _tracerName = 'dartastic_otel_libs_paystack';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class PaystackResult {
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

class PaystackCallResult<T> {
  const PaystackCallResult({required this.value, this.result});
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
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.environment != null) {
        extras.add(OTel.attributeString(
          'paystack.environment',
          res.environment!,
        ));
      }
      if (res.reference != null) {
        extras.add(OTel.attributeString(
          'paystack.reference',
          res.reference!,
        ));
      }
      if (res.amountSubunits != null) {
        extras.add(OTel.attributeInt(
          'paystack.amount.subunits',
          res.amountSubunits!,
        ));
      }
      if (res.currency != null) {
        extras.add(OTel.attributeString('paystack.currency', res.currency!));
      }
      if (res.country != null) {
        extras.add(OTel.attributeString('paystack.country', res.country!));
      }
      if (res.channel != null) {
        extras.add(OTel.attributeString('paystack.channel', res.channel!));
      }
      if (res.cardNetwork != null) {
        extras.add(OTel.attributeString(
          'paystack.card.network',
          res.cardNetwork!,
        ));
      }
      if (res.cardBin != null) {
        extras.add(OTel.attributeString('paystack.card.bin', res.cardBin!));
      }
      if (res.cardLast4 != null) {
        extras.add(OTel.attributeString(
          'paystack.card.last4',
          res.cardLast4!,
        ));
      }
      if (res.cardAuthorizationCode != null) {
        extras.add(OTel.attributeString(
          'paystack.card.authorization_code',
          res.cardAuthorizationCode!,
        ));
      }
      if (res.cardReusable != null) {
        extras.add(OTel.attributeBool(
          'paystack.card.reusable',
          res.cardReusable!,
        ));
      }
      if (res.bankCode != null) {
        extras.add(OTel.attributeString('paystack.bank.code', res.bankCode!));
      }
      if (res.transferRecipientCode != null) {
        extras.add(OTel.attributeString(
          'paystack.transfer.recipient_code',
          res.transferRecipientCode!,
        ));
      }
      if (res.transactionStatus != null) {
        extras.add(OTel.attributeString(
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
        extras.add(OTel.attributeString(
          'paystack.gateway.response',
          res.gatewayResponse!,
        ));
      }
      if (res.feesSubunits != null) {
        extras.add(OTel.attributeInt(
          'paystack.fees.subunits',
          res.feesSubunits!,
        ));
      }
      if (res.subaccountCode != null) {
        extras.add(OTel.attributeString(
          'paystack.subaccount.code',
          res.subaccountCode!,
        ));
      }
      if (res.planCode != null) {
        extras.add(OTel.attributeString('paystack.plan.code', res.planCode!));
      }
      if (res.subscriptionCode != null) {
        extras.add(OTel.attributeString(
          'paystack.subscription.code',
          res.subscriptionCode!,
        ));
      }
      if (res.subscriptionStatus != null) {
        extras.add(OTel.attributeString(
          'paystack.subscription.status',
          res.subscriptionStatus!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'paystack.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Paystack ${res.errorCode}');
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
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
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
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
