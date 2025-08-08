import React from 'react';
import { useParams } from 'react-router-dom';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

function GamePlayPage() {
  const { bazaarName, gameType } = useParams();

  return (
    <Container maxWidth="lg" sx={{ py: 5 }}>
      <Box sx={{ textAlign: 'center' }}>
        <Typography variant="h4" component="h1" sx={{ fontWeight: 600, color: '#333' }}>
          {bazaarName.replace('-', ' ').toUpperCase()} - {gameType.replace('-', ' ').toUpperCase()}
        </Typography>
        <Typography variant="body1" sx={{ mt: 3, color: '#666', fontSize: '1rem' }}>
          Game setup screen is under development.
        </Typography>
      </Box>
    </Container>
  );
}

export default GamePlayPage;

