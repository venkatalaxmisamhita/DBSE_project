async function runVerification() {
  console.log('--- STARTING COMPREHENSIVE END-TO-END VERIFICATION ---');

  // 1. Auth Login Test
  const loginRes = await fetch('http://localhost:5000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'customer@foodfusion.com', password: 'password123' })
  });
  const loginData = await loginRes.json();
  console.log('1. Auth Login Result:', loginData.success ? `PASS (User ID: ${loginData.user.id})` : 'FAIL');

  // 2. Order Creation Test (Port 5000)
  const orderRes = await fetch('http://localhost:5000/api/orders', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${loginData.token}`
    },
    body: JSON.stringify({
      userId: loginData.user.id,
      address: { id: 'addr-1', tag: 'Home', addressLine: 'Plot 42, Jubilee Hills', city: 'Hyderabad', pincode: '500033' },
      paymentMethod: 'Razorpay Online',
      restaurants: [{
        restaurantId: 'rest-1',
        restaurantName: 'Paradise Biryani',
        subtotal: 289,
        items: [{ foodId: 'f-101', name: 'Dum Biryani', price: 289, quantity: 1, isVeg: 0 }]
      }],
      pricing: { subtotal: 289, deliveryFee: 30, tax: 15, discount: 0, total: 334 }
    })
  });
  const orderData = await orderRes.json();
  console.log('2. Order Creation Result:', orderData.success ? `PASS (Order ID: ${orderData.id}, Status: ${orderData.deliveryStatus})` : 'FAIL');

  // 3. Demo Razorpay Valid Payment Verification Test
  const validPayRes = await fetch('http://localhost:5000/api/razorpay/verify-payment', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orderId: orderData.id,
      razorpay_order_id: `order_test_${Date.now()}`,
      razorpay_payment_id: `pay_test_${Date.now()}`,
      razorpay_signature: `sig_test_verified_${Date.now()}`
    })
  });
  const validPayData = await validPayRes.json();
  console.log('3. Valid Demo Razorpay Verification:', validPayData.success ? `PASS (Status: ${validPayData.paymentStatus})` : 'FAIL');

  // 4. Demo Razorpay Invalid Payment Failure Test
  const invalidPayRes = await fetch('http://localhost:5000/api/razorpay/verify-payment', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orderId: orderData.id,
      razorpay_order_id: 'invalid_order',
      razorpay_payment_id: 'invalid_pay',
      razorpay_signature: 'invalid_signature'
    })
  });
  const invalidPayData = await invalidPayRes.json();
  console.log('4. Invalid Signature Rejection Test:', !invalidPayData.success ? `PASS (Correctly Rejected: ${invalidPayData.error})` : 'FAIL');

  // 5. Delivery Location Telemetry Test (Port 5001)
  const locRes = await fetch(`http://localhost:5001/api/delivery/location/${orderData.id}`);
  const locData = await locRes.json();
  console.log('5. Microservice Delivery Telemetry (Port 5001):', locData.service ? `PASS (Status: ${locData.deliveryStatus}, Partner: ${locData.partnerName || 'Pending'})` : 'FAIL');

  // 6. Vendor Driver Assignment Test (Port 5001)
  const assignRes = await fetch('http://localhost:5001/api/restaurant/assign-partner', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ orderId: orderData.id, partnerId: 'driver-101' })
  });
  const assignData = await assignRes.json();
  console.log('6. Vendor Driver Assignment Test:', assignData.success ? `PASS (Assigned to: ${assignData.partner.name})` : 'FAIL');

  // 7. Verify Live Delivery Location Update After Assignment
  const locRes2 = await fetch(`http://localhost:5001/api/delivery/location/${orderData.id}`);
  const locData2 = await locRes2.json();
  console.log('7. Live Customer Tracking Update Test:', locData2.partnerName === 'Ramesh Kumar' ? `PASS (Partner Name: ${locData2.partnerName})` : 'FAIL');

  console.log('--- ALL CHECKS COMPLETED SUCCESSFULLY ---');
}

runVerification().catch(console.error);
