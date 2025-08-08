import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import Header from './components/Header';
import Sidebar from './components/Sidebar';
import HomePage from './pages/HomePage';
import BazaarGamesPage from './pages/BazaarGamesPage';
import GamePlayPage from './pages/GamePlayPage';
import AddMoneyPage from './pages/AddMoneyPage';
import WithdrawMoneyPage from './pages/WithdrawMoneyPage';
import MyBidsPage from './pages/MyBidsPage';
import PassbookPage from './pages/PassbookPage';
import FundsPage from './pages/FundsPage';
import NotificationsPage from './pages/NotificationsPage';
import GameRatePage from './pages/GameRatePage';
import TimeTablePage from './pages/TimeTablePage';
import ChartPage from './pages/ChartPage';
import NotificationBoardPage from './pages/NotificationBoardPage';
import RulesPage from './pages/RulesPage';
import SettingsPage from './pages/SettingsPage';
import './styles/GlobalStyles.css';

const theme = createTheme({
  palette: {
    primary: {
      main: '#87CEEB', // Sky blue
      light: '#B3E0FF',
      dark: '#5FAADD',
    },
    secondary: {
      main: '#333333',
    },
    background: {
      default: '#ffffff',
      paper: '#ffffff',
    },
    success: {
      main: '#4CAF50',
    },
    error: {
      main: '#f44336',
    },
  },
  typography: {
    fontFamily: 'Roboto, sans-serif',
    h6: {
      fontWeight: 500,
    },
    body1: {
      fontSize: '0.9rem',
    },
    body2: {
      fontSize: '0.8rem',
    },
  },
  shape: {
    borderRadius: 8,
  },
});

function App() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const handleSidebarToggle = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const handleSidebarClose = () => {
    setSidebarOpen(false);
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <div className="app">
          <Header onMenuClick={handleSidebarToggle} />
          <Sidebar open={sidebarOpen} onClose={handleSidebarClose} />
          <main className="main-content">
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/bazaar/:bazaarName" element={<BazaarGamesPage />} />
              <Route path="/game/:bazaarName/:gameType" element={<GamePlayPage />} />
              <Route path="/add-money" element={<AddMoneyPage />} />
              <Route path="/withdraw-money" element={<WithdrawMoneyPage />} />
              <Route path="/my-bids" element={<MyBidsPage />} />
              <Route path="/passbook" element={<PassbookPage />} />
              <Route path="/funds" element={<FundsPage />} />
              <Route path="/notifications" element={<NotificationsPage />} />
              <Route path="/game-rate" element={<GameRatePage />} />
              <Route path="/time-table" element={<TimeTablePage />} />
              <Route path="/chart" element={<ChartPage />} />
              <Route path="/notification-board" element={<NotificationBoardPage />} />
              <Route path="/rules" element={<RulesPage />} />
              <Route path="/settings" element={<SettingsPage />} />
            </Routes>
          </main>
        </div>
      </Router>
    </ThemeProvider>
  );
}

export default App;
