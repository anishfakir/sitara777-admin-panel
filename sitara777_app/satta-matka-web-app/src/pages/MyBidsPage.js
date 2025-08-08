import React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

function MyBidsPage() {
  return (
    <Container maxWidth="lg" sx={{ py: 5 }}>
      <Box sx={{ textAlign: 'center' }}>
        <Typography variant="h4" component="h1" sx={{ fontWeight: 600, color: '#333' }}>
          My Bids
        </Typography>
        <Typography variant="body1" sx={{ mt: 3, color: '#666', fontSize: '1rem' }}>
          Your bid history will be displayed here.
        </Typography>
      </Box>
    </Container>
  );
}

export default MyBidsPage;
