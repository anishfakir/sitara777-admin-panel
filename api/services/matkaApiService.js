const axios = require('axios');
const moment = require('moment');
const FormData = require('form-data');

class MatkaApiService {
    constructor() {
        this.baseUrl = 'https://matkawebhook.matka-api.online';
        this.username = process.env.MATKA_API_USERNAME || '7405035755';
        this.password = process.env.MATKA_API_PASSWORD || 'Anish@007';
        this.maharashtraToken = process.env.MAHARASHTRA_TOKEN || 'gF2v4vyE2kij0NWh';
        this.delhiToken = null;
        this.tokenExpiry = null;
    }

    /**
     * Get refresh token for Maharashtra Market
     */
    async getRefreshToken() {
        try {
            const formData = new FormData();
            formData.append('username', this.username);
            formData.append('password', this.password);

            const response = await axios.post(`${this.baseUrl}/get-refresh-token`, formData, {
                headers: {
                    ...formData.getHeaders()
                }
            });

            if (response.data && response.data.token) {
                this.maharashtraToken = response.data.token;
                this.tokenExpiry = moment().add(24, 'hours'); // Assuming 24-hour expiry
                console.log('✅ Maharashtra token refreshed successfully');
                return response.data;
            }

            throw new Error('Failed to get refresh token');
        } catch (error) {
            console.error('❌ Error getting refresh token:', error.message);
            throw error;
        }
    }

    /**
     * Get refresh token for Delhi Market
     */
    async getDelhiRefreshToken() {
        try {
            const formData = new FormData();
            formData.append('username', this.username);
            formData.append('password', this.password);

            const response = await axios.post(`${this.baseUrl}/get-refresh-token-delhi`, formData, {
                headers: {
                    ...formData.getHeaders()
                }
            });

            if (response.data && response.data.token) {
                this.delhiToken = response.data.token;
                console.log('✅ Delhi token refreshed successfully');
                return response.data;
            }

            throw new Error('Failed to get Delhi refresh token');
        } catch (error) {
            console.error('❌ Error getting Delhi refresh token:', error.message);
            throw error;
        }
    }

    /**
     * Check if token needs refresh
     */
    needsTokenRefresh() {
        return !this.tokenExpiry || moment().isAfter(this.tokenExpiry);
    }

    /**
     * Get market data for Maharashtra Market
     */
    async getMarketData(date = null, marketName = 'Maharashtra Market') {
        try {
            // Refresh token if needed
            if (this.needsTokenRefresh()) {
                await this.getRefreshToken();
            }

            const targetDate = date || moment().format('YYYY-MM-DD');
            
            const formData = new FormData();
            formData.append('username', this.username);
            formData.append('API_token', this.maharashtraToken);
            formData.append('markte_name', marketName);
            formData.append('date', targetDate);

            const response = await axios.post(`${this.baseUrl}/market-data`, formData, {
                headers: {
                    ...formData.getHeaders()
                }
            });

            if (response.data) {
                console.log(`✅ Market data retrieved for ${marketName} on ${targetDate}`);
                return {
                    success: true,
                    data: response.data,
                    date: targetDate,
                    market: marketName
                };
            }

            throw new Error('No data received from API');
        } catch (error) {
            console.error('❌ Error getting market data:', error.message);
            return {
                success: false,
                error: error.message,
                date: date,
                market: marketName
            };
        }
    }

    /**
     * Get market data for Delhi Market
     */
    async getDelhiMarketData(date = null, marketName = 'Maharashtra Market') {
        try {
            // Refresh Delhi token if needed
            if (!this.delhiToken) {
                await this.getDelhiRefreshToken();
            }

            const targetDate = date || moment().format('YYYY-MM-DD');
            
            const formData = new FormData();
            formData.append('username', this.username);
            formData.append('API_token', this.delhiToken);
            formData.append('markte_name', marketName);
            formData.append('date', targetDate);

            const response = await axios.post(`${this.baseUrl}/market-data-delhi`, formData, {
                headers: {
                    ...formData.getHeaders()
                }
            });

            if (response.data) {
                console.log(`✅ Delhi market data retrieved for ${marketName} on ${targetDate}`);
                return {
                    success: true,
                    data: response.data,
                    date: targetDate,
                    market: marketName
                };
            }

            throw new Error('No data received from Delhi API');
        } catch (error) {
            console.error('❌ Error getting Delhi market data:', error.message);
            return {
                success: false,
                error: error.message,
                date: date,
                market: marketName
            };
        }
    }

    /**
     * Get market mapping
     */
    async getMarketMapping() {
        try {
            // Refresh token if needed
            if (this.needsTokenRefresh()) {
                await this.getRefreshToken();
            }

            const formData = new FormData();
            formData.append('username', this.username);
            formData.append('API_token', this.maharashtraToken);

            const response = await axios.post(`${this.baseUrl}/market-mapping`, formData, {
                headers: {
                    ...formData.getHeaders()
                }
            });

            if (response.data) {
                console.log('✅ Market mapping retrieved successfully');
                return {
                    success: true,
                    data: response.data
                };
            }

            throw new Error('No mapping data received from API');
        } catch (error) {
            console.error('❌ Error getting market mapping:', error.message);
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Auto-sync results for multiple dates
     */
    async autoSyncResults(startDate, endDate = null) {
        const results = [];
        const start = moment(startDate);
        const end = endDate ? moment(endDate) : moment();

        console.log(`🔄 Starting auto-sync from ${start.format('YYYY-MM-DD')} to ${end.format('YYYY-MM-DD')}`);

        while (start.isSameOrBefore(end)) {
            const dateStr = start.format('YYYY-MM-DD');
            
            try {
                // Get Maharashtra Market data
                const maharashtraData = await this.getMarketData(dateStr);
                results.push({
                    date: dateStr,
                    market: 'Maharashtra Market',
                    ...maharashtraData
                });

                // Small delay to avoid rate limiting
                await new Promise(resolve => setTimeout(resolve, 1000));

                // Get Delhi Market data
                const delhiData = await this.getDelhiMarketData(dateStr);
                results.push({
                    date: dateStr,
                    market: 'Delhi Market',
                    ...delhiData
                });

                // Small delay to avoid rate limiting
                await new Promise(resolve => setTimeout(resolve, 1000));

            } catch (error) {
                console.error(`❌ Error syncing data for ${dateStr}:`, error.message);
                results.push({
                    date: dateStr,
                    success: false,
                    error: error.message
                });
            }

            start.add(1, 'day');
        }

        console.log(`✅ Auto-sync completed. Processed ${results.length} requests`);
        return results;
    }

    /**
     * Transform external API data to internal format
     */
    transformToInternalFormat(externalData, market, date) {
        try {
            // This method should be customized based on the actual response format
            // from the Maharashtra Market API
            
            return {
                market: market,
                date: date,
                openResult: externalData.open || null,
                closeResult: externalData.close || null,
                jodi: externalData.jodi || null,
                singlePanna: externalData.single_panna || null,
                doublePanna: externalData.double_panna || null,
                triplePanna: externalData.triple_panna || null,
                rawData: externalData,
                source: 'external_api',
                createdAt: new Date(),
                updatedAt: new Date()
            };
        } catch (error) {
            console.error('❌ Error transforming data:', error.message);
            return null;
        }
    }
}

module.exports = new MatkaApiService();
