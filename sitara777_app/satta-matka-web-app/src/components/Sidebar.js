import React from 'react';
import { useNavigate } from 'react-router-dom';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Divider from '@mui/material/Divider';
import HomeIcon from '@mui/icons-material/Home';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import AttachMoneyIcon from '@mui/icons-material/AttachMoney';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import ReceiptIcon from '@mui/icons-material/Receipt';
import NotificationsIcon from '@mui/icons-material/Notifications';
import InfoIcon from '@mui/icons-material/Info';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import BarChartIcon from '@mui/icons-material/BarChart';
import AnnouncementIcon from '@mui/icons-material/Announcement';
import GavelIcon from '@mui/icons-material/Gavel';
import SettingsIcon from '@mui/icons-material/Settings';
import ShareIcon from '@mui/icons-material/Share';
import LogoutIcon from '@mui/icons-material/Logout';

const menuItems = [
  { text: 'Home', icon: <HomeIcon />, path: '/' },
  { text: 'Add Money', icon: <AttachMoneyIcon />, path: '/add-money' },
  { text: 'Withdraw Money', icon: <AccountBalanceWalletIcon />, path: '/withdraw-money' },
  { text: 'My Bids', icon: <ShoppingCartIcon />, path: '/my-bids' },
  { text: 'Passbook', icon: <ReceiptIcon />, path: '/passbook' },
  { text: 'Funds', icon: <AccountBalanceWalletIcon />, path: '/funds' },
  { text: 'Notifications', icon: <NotificationsIcon />, path: '/notifications' },
  { text: 'Game Rate', icon: <InfoIcon />, path: '/game-rate' },
  { text: 'Time Table', icon: <AccessTimeIcon />, path: '/time-table' },
  { text: 'Chart', icon: <BarChartIcon />, path: '/chart' },
  { text: 'Notification Board', icon: <AnnouncementIcon />, path: '/notification-board' },
  { text: 'Rules', icon: <GavelIcon />, path: '/rules' },
  { text: 'Settings', icon: <SettingsIcon />, path: '/settings' },
  { text: 'Share App', icon: <ShareIcon />, action: 'share' },
  { text: 'Logout', icon: <LogoutIcon />, action: 'logout' },
];

function Sidebar({ open, onClose }) {
  const navigate = useNavigate();

  const handleMenuClick = (item) => {
    if (item.action === 'share') {
      if (navigator.share) {
        navigator.share({
          title: 'Satta Matka App',
          text: 'Check out this amazing Satta Matka app!',
          url: window.location.origin
        });
      } else {
        alert('Sharing is not supported on this device');
      }
    } else if (item.action === 'logout') {
      // Handle logout logic here
      alert('Logout functionality will be implemented');
    } else if (item.path) {
      navigate(item.path);
    }
    onClose();
  };

  return (
    <Drawer
      anchor="left"
      open={open}
      onClose={onClose}
      sx={{
        '& .MuiDrawer-paper': {
          width: 280,
          backgroundColor: '#ffffff',
          borderRight: '1px solid #e0e0e0',
        },
      }}
    >
      <div style={{ padding: '20px 16px', backgroundColor: '#87CEEB', color: 'white' }}>
        <h3 style={{ margin: 0, fontSize: '18px', fontWeight: 500 }}>Satta Matka</h3>
        <p style={{ margin: '4px 0 0', fontSize: '14px', opacity: 0.9 }}>Welcome to the game</p>
      </div>
      
      <List sx={{ padding: '8px 0' }}>
        {menuItems.map((item, index) => (
          <React.Fragment key={item.text}>
            {(index === 6 || index === 12) && <Divider sx={{ my: 1 }} />}
            <ListItem disablePadding>
              <ListItemButton
                onClick={() => handleMenuClick(item)}
                sx={{
                  padding: '12px 20px',
                  '&:hover': {
                    backgroundColor: '#f0f8ff',
                  },
                }}
              >
                <ListItemIcon
                  sx={{
                    color: '#87CEEB',
                    minWidth: 40,
                  }}
                >
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={item.text}
                  sx={{
                    '& .MuiListItemText-primary': {
                      fontSize: '15px',
                      fontWeight: 400,
                      color: '#333',
                    },
                  }}
                />
              </ListItemButton>
            </ListItem>
          </React.Fragment>
        ))}
      </List>
    </Drawer>
  );
}

export default Sidebar;
