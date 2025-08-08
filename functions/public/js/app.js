// Sitara777 Admin Panel JavaScript

$(document).ready(function() {
    // Sidebar toggle
    $('#sidebarCollapse').on('click', function() {
        $('#sidebar').toggleClass('active');
        $('#content').toggleClass('active');
    });

    // Auto-hide alerts after 5 seconds
    setTimeout(function() {
        $('.alert').fadeOut('slow');
    }, 5000);

    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Initialize popovers
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });

    // Form validation
    $('form').on('submit', function() {
        var $form = $(this);
        var $submitBtn = $form.find('button[type="submit"]');
        
        // Disable submit button and show loading
        $submitBtn.prop('disabled', true);
        $submitBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Loading...');
        
        // Re-enable after 3 seconds (fallback)
        setTimeout(function() {
            $submitBtn.prop('disabled', false);
            $submitBtn.html($submitBtn.data('original-text') || 'Submit');
        }, 3000);
    });

    // AJAX form submissions
    $('.ajax-form').on('submit', function(e) {
        e.preventDefault();
        
        var $form = $(this);
        var $submitBtn = $form.find('button[type="submit"]');
        var originalText = $submitBtn.text();
        
        // Show loading state
        $submitBtn.prop('disabled', true);
        $submitBtn.html('<span class="spinner-border spinner-border-sm"></span> Processing...');
        
        $.ajax({
            url: $form.attr('action'),
            method: $form.attr('method'),
            data: $form.serialize(),
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message || 'Operation completed successfully');
                    if (response.redirect) {
                        setTimeout(function() {
                            window.location.href = response.redirect;
                        }, 1500);
                    }
                } else {
                    showAlert('danger', response.error || 'Operation failed');
                }
            },
            error: function(xhr) {
                var message = 'An error occurred';
                if (xhr.responseJSON && xhr.responseJSON.error) {
                    message = xhr.responseJSON.error;
                }
                showAlert('danger', message);
            },
            complete: function() {
                // Reset button state
                $submitBtn.prop('disabled', false);
                $submitBtn.text(originalText);
            }
        });
    });

    // Toggle bazaar status
    $('.toggle-bazaar-status').on('click', function() {
        var $btn = $(this);
        var bazaarId = $btn.data('bazaar-id');
        var $statusBadge = $btn.closest('tr').find('.status-badge');
        
        $.ajax({
            url: `/bazaar/toggle/${bazaarId}`,
            method: 'POST',
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
                    
                    // Update UI
                    if (response.isOpen) {
                        $btn.removeClass('btn-success').addClass('btn-danger');
                        $btn.html('<i class="fas fa-times"></i> Close');
                        $statusBadge.removeClass('bg-secondary').addClass('bg-success').text('Open');
                    } else {
                        $btn.removeClass('btn-danger').addClass('btn-success');
                        $btn.html('<i class="fas fa-check"></i> Open');
                        $statusBadge.removeClass('bg-success').addClass('bg-secondary').text('Closed');
                    }
                } else {
                    showAlert('danger', response.error || 'Failed to toggle status');
                }
            },
            error: function() {
                showAlert('danger', 'Failed to toggle bazaar status');
            }
        });
    });

    // Delete bazaar
    $('.delete-bazaar').on('click', function() {
        if (!confirm('Are you sure you want to delete this bazaar?')) {
            return;
        }
        
        var $btn = $(this);
        var bazaarId = $btn.data('bazaar-id');
        
        $.ajax({
            url: `/bazaar/delete/${bazaarId}`,
            method: 'POST',
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
                    $btn.closest('tr').fadeOut();
                } else {
                    showAlert('danger', response.error || 'Failed to delete bazaar');
                }
            },
            error: function() {
                showAlert('danger', 'Failed to delete bazaar');
            }
        });
    });

    // Update bazaar result
    $('.update-result').on('click', function() {
        var $btn = $(this);
        var bazaarId = $btn.data('bazaar-id');
        var result = prompt('Enter new result:');
        
        if (result === null) return; // User cancelled
        
        $.ajax({
            url: `/bazaar/result/${bazaarId}`,
            method: 'POST',
            data: { result: result },
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
                    $btn.closest('tr').find('.result-display').text(result);
                } else {
                    showAlert('danger', response.error || 'Failed to update result');
                }
            },
            error: function() {
                showAlert('danger', 'Failed to update result');
            }
        });
    });

    // Approve withdrawal
    $('.approve-withdrawal').on('click', function() {
        if (!confirm('Are you sure you want to approve this withdrawal?')) {
            return;
        }
        
        var $btn = $(this);
        var withdrawalId = $btn.data('withdrawal-id');
        
        $.ajax({
            url: `/withdrawals/approve/${withdrawalId}`,
            method: 'POST',
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
                    $btn.closest('tr').find('.status-badge').removeClass('bg-warning').addClass('bg-success').text('Approved');
                    $btn.remove();
                } else {
                    showAlert('danger', response.error || 'Failed to approve withdrawal');
                }
            },
            error: function() {
                showAlert('danger', 'Failed to approve withdrawal');
            }
        });
    });

    // Reject withdrawal
    $('.reject-withdrawal').on('click', function() {
        if (!confirm('Are you sure you want to reject this withdrawal?')) {
            return;
        }
        
        var $btn = $(this);
        var withdrawalId = $btn.data('withdrawal-id');
        
        $.ajax({
            url: `/withdrawals/reject/${withdrawalId}`,
            method: 'POST',
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
                    $btn.closest('tr').find('.status-badge').removeClass('bg-warning').addClass('bg-danger').text('Rejected');
                    $btn.remove();
                } else {
                    showAlert('danger', response.error || 'Failed to reject withdrawal');
                }
            },
            error: function() {
                showAlert('danger', 'Failed to reject withdrawal');
            }
        });
    });

    // Send notification
    $('#sendNotificationForm').on('submit', function(e) {
        e.preventDefault();
        
        var $form = $(this);
        var $submitBtn = $form.find('button[type="submit"]');
        var originalText = $submitBtn.text();
        
        $submitBtn.prop('disabled', true);
        $submitBtn.html('<span class="spinner-border spinner-border-sm"></span> Sending...');
        
        $.ajax({
            url: '/notifications/send',
            method: 'POST',
            data: $form.serialize(),
            success: function(response) {
                if (response.success) {
                    showAlert('success', response.message);
                    $form[0].reset();
                } else {
                    showAlert('danger', response.error || 'Failed to send notification');
                }
            },
            error: function() {
                showAlert('danger', 'Failed to send notification');
            },
            complete: function() {
                $submitBtn.prop('disabled', false);
                $submitBtn.text(originalText);
            }
        });
    });

    // Real-time updates
    if (typeof WebSocket !== 'undefined') {
        // Initialize WebSocket for real-time updates
        // This can be implemented for live dashboard updates
    }

    // Auto-refresh dashboard stats
    if (window.location.pathname === '/dashboard') {
        setInterval(function() {
            $.get('/dashboard/api/stats')
                .done(function(data) {
                    // Update dashboard stats
                    updateDashboardStats(data);
                })
                .fail(function() {
                    console.log('Failed to update dashboard stats');
                });
        }, 30000); // Update every 30 seconds
    }
});

// Utility functions
function showAlert(type, message) {
    var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
    var iconClass = type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle';
    
    var alertHtml = `
        <div class="alert ${alertClass} alert-dismissible fade show" role="alert">
            <i class="${iconClass}"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    // Remove existing alerts
    $('.alert').remove();
    
    // Add new alert
    $('.container-fluid').prepend(alertHtml);
    
    // Auto-hide after 5 seconds
    setTimeout(function() {
        $('.alert').fadeOut('slow');
    }, 5000);
}

function updateDashboardStats(data) {
    // Update statistics cards
    $('.total-users').text(data.totalUsers || 0);
    $('.total-bazaars').text(data.totalBazaars || 0);
    $('.open-bazaars').text(data.openBazaars || 0);
    $('.pending-withdrawals').text(data.pendingWithdrawals || 0);
    $('.total-wallet-balance').text('₹' + (data.totalWalletBalance || '0.00'));
    $('.today-results').text(data.todayResults || 0);
}

function formatCurrency(amount) {
    return '₹' + parseFloat(amount).toLocaleString('en-IN');
}

function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('en-IN');
}

function formatDateTime(dateString) {
    return new Date(dateString).toLocaleString('en-IN');
}

// Export functions for global use
window.showAlert = showAlert;
window.formatCurrency = formatCurrency;
window.formatDate = formatDate;
window.formatDateTime = formatDateTime; 