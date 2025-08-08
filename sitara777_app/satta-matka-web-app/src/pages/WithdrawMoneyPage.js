import React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

function WithdrawMoneyPage() {
  return (
    <Container maxWidth="lg" sx={{ py: 5 }}>
      <Box sx={{ textAlign: 'center' }}>
        <Typography variant="h4" component="h1" sx={{ fontWeight: 600, color: '#333' }}>
          Withdraw Money
        </Typography>
        <Typography variant="body1" sx={{ mt: 3, color: '#666', fontSize: '1rem' }}>
          Withdraw money functionality will be implemented here.
        </Typography>
      </Box>
    </Container>
  );
}

export default WithdrawMoneyPage;
