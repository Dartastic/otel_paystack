// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_paystack/otel_paystack.dart';

/// Traces Paystack calls with OpenTelemetry.
///
/// `otel_paystack` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Paystack call in
/// [tracedPaystack]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'paystack-example');

  // Wraps a Paystack call in a CLIENT span.
  final paystackId = await tracedPaystack<String>(
    operation: 'create',
    invoke: () async {
      // Make the Paystack call here, then report what it returned.
      const id = 'paystack_8f3a2c';
      return const PaystackCallResult(
          value: id,
          result: PaystackResult(
              environment: 'test',
              reference: 'example',
              amountSubunits: 1999,
              currency: 'NGN',
              country: 'NG',
              channel: 'card',
              cardNetwork: 'visa',
              cardBin: 'example',
              cardLast4: 'example',
              cardAuthorizationCode: 'AUTH_3Mtw8f3a2cx',
              cardReusable: true,
              bankCode: 'example',
              transferRecipientCode: 'RCP_3Mtw8f3a2cx',
              transactionStatus: 'success',
              gatewayResponse: 'Successful',
              feesSubunits: 1,
              subaccountCode: 'example',
              planCode: 'example',
              subscriptionCode: 'example',
              subscriptionStatus: 'active',
              errorCode: 'invalid_request',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedPaystack create returned $paystackId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutPaystackInstrumentationAsync.
  await runWithoutPaystackInstrumentationAsync(
    () => tracedPaystack<String>(
      operation: 'create',
      invoke: () async {
        const id = 'paystack_8f3a2c';
        return const PaystackCallResult(
            value: id,
            result: PaystackResult(
                environment: 'test',
                reference: 'example',
                amountSubunits: 1999,
                currency: 'NGN',
                country: 'NG',
                channel: 'card',
                cardNetwork: 'visa',
                cardBin: 'example',
                cardLast4: 'example',
                cardAuthorizationCode: 'AUTH_3Mtw8f3a2cx',
                cardReusable: true,
                bankCode: 'example',
                transferRecipientCode: 'RCP_3Mtw8f3a2cx',
                transactionStatus: 'success',
                gatewayResponse: 'Successful',
                feesSubunits: 1,
                subaccountCode: 'example',
                planCode: 'example',
                subscriptionCode: 'example',
                subscriptionStatus: 'active',
                errorCode: 'invalid_request',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
